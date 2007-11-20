package Rose::DBx::Object::Loader::FormMaker;

use strict;
use warnings;

use Rose::DB::Object::Loader;
use Carp;
use File::Path;
use File::Spec;

BEGIN { our @ISA = qw(Rose::DB::Object::Loader) }

=head1 NAME

Rose::DB::Object::Loader::FormMaker - Automatically create RHTMLO forms for RDBO Objects

=head1 VERSION

version 0.01

=cut

our $VERSION = '0.01';

#
# basically ripped from loader
#
sub make_modules {
    my ($self,%args) = @_;

    my @classes = $self->SUPER::make_modules(%args);

    my $module_dir = exists $args{'module_dir'} ? 
        delete $args{'module_dir'} : $self->module_dir;

    $module_dir = cwd()  unless(defined $module_dir);

    foreach my $class (@classes) {

        next unless ($class->isa('Rose::DB::Object'));

        my $class_name = scalar $class;
	my $class_prefix = $self->class_prefix;
	my $form_prefix = $self->form_prefix;

	$class_name =~ s|$class_prefix|$form_prefix|;
        my @path = split('::', $class_name);
        $path[-1] .= '.pm';
        unshift(@path, $module_dir);

        my $dir = File::Spec->catfile(@path[0 .. ($#path - 1)]);

        mkpath($dir)  unless(-e $dir);

        unless(-d $dir) {
            if(-f $dir) {
                croak "Could not create module directory '$module_dir' - a file ",
                      "with the same name already exists";
            }
            croak "Could not create module directory '$module_dir' - $!";
        }

        my $file = File::Spec->catfile(@path);

        open(my $pm, '>', $file) or croak "Could not create $file - $!";

        my $preamble = exists $args{'module_preamble'} ? 
            $args{'module_preamble'} : $self->module_preamble;

        my $postamble = exists $args{'module_postamble'} ? 
            $args{'module_postamble'} : $self->module_postamble;

        if ($class->isa('Rose::DB::Object')) {
            if($preamble) {
                my $this_preamble = ref $preamble eq 'CODE' ? 
                    $preamble->($class->meta) : $preamble;

                print {$pm} $this_preamble;
            }

            print {$pm} $self->class_to_form($class);

            if($postamble) {
                my $this_postamble = ref $postamble eq 'CODE' ? 
                    $postamble->($class->meta) : $postamble;

                print {$pm} $this_postamble;
            }
        }
    }

    return wantarray ? @classes : \@classes; 
}

#
# returns perl for an RHTMLO form based on the RDBO class passed in
#
sub class_to_form {
    my ($self, $class) = @_;
    my $class_name = scalar $class;
    my $class_prefix = $self->class_prefix;
    my $form_prefix = $self->form_prefix;
    $class_name =~ s|$class_prefix|$form_prefix|;
    
    my $code;

    $code .=qq[package $class_name;

use strict;
use warnings;

use Rose::HTML::Form;
our \@ISA = qw(Rose::HTML::Form);

sub build_form {
    my(\$self) = shift;

    \$self->add_fields (
];
    my $count = 1;
    foreach my $column (sort __by_rank $class->meta->columns){
        #print STDERR $column.qq[ ] . $column->type .qq[\n];
        #$code .= $column.qq[\n];
	my $column_name = scalar $column;
        $code .= qq[
        $column_name => {
            id => '$column_name',
	    type => '].$column->type.qq[',
            label => '$column_name',
	    tabindex => $count,
        },];
        $count++;
    }
    $code .= qq[
    );
}
1;
];
    
    return $code;
}


#
# ripped from loader, lets forms have their own prefix
#
sub form_prefix {
    my($self) = shift;

    return $self->{'form_prefix'}  unless(@_);

    my $form_prefix = shift;

    if (length $form_prefix) {
        unless($form_prefix =~ /^(?:\w+::)*\w+(?:::)?$/) {
            croak "Illegal class prefix: $form_prefix";
        }
        $form_prefix .= '::'  unless($form_prefix =~ /::$/);
    }

    return $self->{'form_prefix'} = $form_prefix;
}

#
# ripped from loader to sort columns
#
sub __by_rank {  
  my $pos1 = $a->ordinal_position;
  my $pos2 = $b->ordinal_position;

  if(defined $pos1 && defined $pos2)
  {
    return $pos1 <=> $pos2 || lc($a->name) cmp lc($b->name);
  }

  return lc($a->name) cmp lc($b->name);
}
