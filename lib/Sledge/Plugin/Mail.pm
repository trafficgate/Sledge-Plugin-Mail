package Sledge::Plugin::Mail;
# $Id: Mail.pm,v 1.12 2002/04/24 18:11:28 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Limited.
#

use strict;
use vars qw($VERSION);
$VERSION = 0.06;

use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(to sender _tmpl filter));

use Edge::Mailer;

use vars qw($SendVia);
$SendVia = 'localhost';

sub import {
    my $class = shift;
    my $pkg = caller;

    no strict 'refs';
    *{"$pkg\::init_mail"} = sub {
        my($self, $name) = @_;
        # template load
        $self->{mail} = $self->create_mail($name);
    };
    *{"$pkg\::create_mail"} = sub {
        my($self, $name) = @_;
        return $class->new($name, $self);
    };
    *{"$pkg\::mail"} = sub {
        my $self = shift;
        $self->{mail};
    };
}

sub new {
    my($class, $name, $page) = @_;
    my $self = bless {}, $class;

    $name .= '.eml' if $name !~ /\./;

    my $file = $page->can('mail_tmpl_dirname')
        ? join("/", $page->create_config->tmpl_path, $page->mail_tmpl_dirname, $name)
            : $page->guess_filename($name);

    $self->_tmpl($page->create_template($file));
    return $self;
}

sub param {
    my $self = shift;
    $self->_tmpl->param(@_);
}

sub send {
    my $self = shift;

    # $SendVia = "smtp.example.com" || "| /usr/sbin/sendmail"
    my($host, $method, @send_args) = _choose_way($SendVia);
    my $mailer = Edge::Mailer->new(
        to       => $self->to,
        sender   => $self->sender,
        smtphost => $host,
        filter   => $self->filter,
        message  => $self->_tmpl->output,
    );

    $mailer->$method(@send_args);
}

sub _choose_way {
    my $via = shift;
    if ($via =~ s/^\|\s*//) {
        # | /path/to/sendmail
        return (undef, 'send_via_sendmail', $via);
    }
    return ($via, 'send');
}
