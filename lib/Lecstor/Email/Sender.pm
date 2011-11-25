package Lecstor::Email::Sender;
use Moose;
use namespace::autoclean;

# ABSTRACT: send multi-part text/html emails

use Carp;
use Encode qw(encode decode);
use Email::Sender::Simple;
use Email::MIME::Creator;
use Email::Sender::Transport::Sendmail;
use Template;

=head1 SYNOPSIS

    $sender = Lecstor::EmailSender->new();

    $sender->send({
        to          => 'jshirley@gmail.com',
        from        => 'no-reply@foobar.com',
        subject     => 'I am a Catalyst generated email',
        content_type => 'text/plain',
        body => 'blah blah blah blah blah',
    });

    $sender->send({
        template => {
            html => 'path/to/html_template.tt',
            plain => 'path/to/text_template.tt',
        },
        to          => 'jshirley@gmail.com',
        cc          => 'abraxxa@cpan.org',
        bcc         => 'hidden@secret.com hidden2@foobar.com',
        from        => 'no-reply@foobar.com',
        subject     => 'I am a Catalyst generated email',
        content_type => 'multipart/alternative',
        stash => $template_data_hash,
    });

=attr template

L<Template> object

=cut

has 'template' => ( isa => 'Object', is => 'ro', lazy_build => 1 );

sub _build_template{ Template->new }

=attr template_prefix

=cut

has 'template_prefix' => ( isa => 'Str', is => 'rw', lazy_build => 1 );

sub _build_template_prefix{ '' }

=attr transport

=cut

has transport => ( isa => 'Email::Sender::Transport', is => 'ro' );

sub _build_transport{
    Email::Sender::Transport::Sendmail->new()
}

=method send

    $sender->send({
        to          => 'jshirley@gmail.com',
        from        => 'no-reply@foobar.com',
        subject     => 'I am a Catalyst generated email',
        content_type => 'text/plain',
        body => 'blah blah blah blah blah',
    });

    $sender->send({
        template => {
          html => 'path/to/html_template.tt',
          plain => 'path/to/text_template.tt',
        },
        to          => 'jshirley@gmail.com',
        cc          => 'abraxxa@cpan.org',
        bcc         => 'hidden@secret.com hidden2@foobar.com',
        from        => 'no-reply@foobar.com',
        subject     => 'I am a Catalyst generated email',
        content_type => 'multipart/alternative',
        stash => $template_data_hash,
    });

=cut

sub send{
    my ($self, $args) = @_;

    my $header = $args->{header} || [];
    push @$header, ( 'To' => delete $args->{to} ) if $args->{to};
    push @$header, ( 'Cc' => delete $args->{cc} ) if $args->{cc};
    push @$header, ( 'Bcc' => delete $args->{bcc} ) if $args->{bcc};
    push @$header, ( 'From' => delete $args->{from} ) if $args->{from};
    push @$header, ( 'Subject' => Encode::encode( 'MIME-Header', delete $args->{subject} ) ) if $args->{subject};
    push @$header, ( 'Content-type' => $args->{content_type} ) if $args->{content_type};

    my ($body,@parts);

    if ($args->{template}){
        if (ref $args->{template}){
            foreach my $type (qw! plain html !){
                next unless $args->{template}{$type};
                push(
                    @parts,
                    $self->generate_part({
                        template => $args->{template}{$type},
                        stash => $args->{stash},
                        content_type    => 'text/'.$type,
                        charset         => 'utf-8',
                    })
                );
            }
        } else {
          $body = $self->process_template({
            template => $args->{template},
            stash => $args->{stash} || {},
          });
        }
    } else {
      $body = $args->{body};
    }

    my %attrs;
    $attrs{content_type} = $args->{content_type} if $args->{content_type};

    my %mime = ( header => $header, attributes => \%attrs );

    if (@parts){
        $mime{parts} = \@parts;
    } else {
        $mime{body} = $body;
    }

    my $message = Email::MIME->create( %mime );

    if ($message) {
        my $return = Email::Sender::Simple->send(
            $message, { transport => $self->transport }
        );

        # return is a Return::Value object, so this will stringify as the error
        # in the case of a failure.
        croak "$return" if !$return;
        return $return;
    }
    else {
        croak "Unable to create message";
    }

}

=method generate_part

    $part = $sender->generate_part({
        template => 'path/to/template.tt',
        content_type    => 'text/html',
        charset         => 'utf-8',
    });

    $part = $sender->generate_part({
        body => 'blah blah blah blah blah',
        content_type    => 'text/plain',
        charset         => 'utf-8',
    });

=cut

sub generate_part{
    my ($self, $args) = @_;

    if ($args->{template}){
        $args->{body} = $self->process_template({
            template => $args->{template},
            stash => $args->{stash},
        });
    }

    return Email::MIME->create(
        attributes => { 'content_type' => $args->{content_type} },
        body       => $args->{body},
    );

}

=attr process_template

    $text = $sender->process_template({
        template => 'path/to/template.tt',
        stash => $template_data_hash,
    });

=cut

sub process_template{
    my ($self, $args) = @_;

    my $template = $args->{template};

    unless (ref $template){
        $template =
            $self->template_prefix ne ''
            ? join( '/', $self->template_prefix, $template )
            : $template;
    }
    my $output;
    $self->template->process( $template, $args->{stash}, \$output) or die $self->template->error;
    return $output;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

