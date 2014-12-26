package Cpanel::Easy::ModWSGI; 

our $easyconfig = { 
    'name'      => 'Mod WSGI', 
    'url'       => 'http://code.google.com/p/modwsgi', 
    'note'      => 'Adds support for Python WSGI modules for Apache 2.x only (Custom apache module by Chris Hallgren and Hallgren Networks)', 
    'hastargz'  => 1, 
    'ensurepkg' => ['python-devel'], 
    'src_cd2'   => 'mod_wsgi-4.4',
    'modself'  => sub { 
        my ( $easy, $self_hr, $profile_hr ) = @_;
        if ( $easy->get_ns_value_from_profile('Cpanel::Easy::Apache::1', $profile_hr) eq '1' ) {
            $self_hr->{'note'}      = 'mod_wsgi is not enabled for Apache 1.X. You should really consider upgrading to Apache 2.x';
        }
    },
    'step'      => { 
        '0' => { 
            'name' => 'Configuring mod_wsgi', 
            'command' => sub { 
                my( $self ) = @_; 
                 
                local $ENV{'CFLAGS'} =  $ENV{'CFLAGS'};
                $ENV{'CFLAGS'} = join(' ', $ENV{'CFLAGS'}, '-fPIC') if $self->{'cpu_bits'} eq '64';

                return $self->run_system_cmd_returnable([ 
                    qw(./configure --with-apxs=/usr/local/apache/bin/apxs --with-python=/usr/local/bin/python) 
                ]); 
            }, 
        }, 
        '1' => { 
            'name' => 'Making mod_wsgi', 
            'command' => sub { 
                my( $self ) = @_; 
                return $self->run_system_cmd_returnable(['make']); 
            }, 
        }, 
        '2' => { 
            'name' => 'Installing mod_wsgi', 
            'command' => sub { 
                my( $self ) = @_; 
                return $self->run_system_cmd_returnable(['make','install']); 
            }, 
        }, 
        '3' => {    
            'name' => 'Adding mod_wsgi to httpd.conf', 
            'command' => sub {
                my ($self) = @_;
                return $self->ensure_loadmodule_in_httpdconf('wsgi', 'mod_wsgi.so');
            }, 
        }, 
    },
}; 

1;
