package Lecstor::FeedProxy::Diff;
use Moose;

# ABSTRACT: generates a diff as a hashref from two other hashrefs

=head1 SYNOPSIS

  my $bef = {
    name => 'Fred',
    wife => 'Wilma',
    hobby => 'Breaking Rocks',
    friends => [qw! Barney Wilma Betty !],
  };

  my $aft = { 
    name => 'Fred',
    pet => 'Dino',
    hobby => 'Bowling',
    friends => [qw! Barney Betty Dino !],
    kids => [qw! Bam Pebbles !],
  };

  my $differ = Lecstor::FeedProxy::Diff->new;

  my $diff = $diff->differences($bef, $aft);

  $diff: {
    'pet' => 'Dino',
    'wife' => undef,
    'hobby' => 'Bowling',
    'friends' => {
      'remove' => [ 'Wilma' ],
      'add' => [ 'Dino' ]
    },
    'kids' => {
      'add' => [ 'Bam', 'Pebbles' ]
    }
  };

=method differences

    my $diff = $diff->differences($bef, $aft);

=cut

sub differences{
  my ($self, $before, $after) = @_;

  my $diff = {};
  my %done;

  foreach my $key (keys %$before){
    $done{$key} = 1;
    my $bef = $before->{$key};
    my $aft = $after->{$key};
    next unless defined $bef;

    if (ref $bef eq 'ARRAY'){
      my %bef = map { $_ => 1 } @$bef;
      my %aft = map { $_ => 1 } @$aft;
      my %done2;
      foreach my $key2 ( keys %bef ){
        $done2{$key2} = 1;
        unless (exists $aft{$key2}){
          push(@{$diff->{$key}{remove}}, $key2); 
        }
      }
      foreach my $key2 ( keys %aft ){
        next if $done2{$key2};
        push(@{$diff->{$key}{add}}, $key2); 
      }
    } else {
      if (defined $aft){
        $diff->{$key} = $aft if $aft ne $bef;
      } else {
        $diff->{$key} = undef;
      }
    }

  }

  foreach my $key (keys %$after){
    next if $done{$key};
    my $aft = $after->{$key};
    if (ref $aft eq 'ARRAY'){
      foreach(@$aft){
        push(@{$diff->{$key}{add}}, $_); 
      }
    } else {
      $diff->{$key} = $after->{$key};
    }
  }

  return $diff;

}

__PACKAGE__->meta->make_immutable;

1;
