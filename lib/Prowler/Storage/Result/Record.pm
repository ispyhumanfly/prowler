
BEGIN {

    die "You must set the PROWLER_ROOT variable before instantiating Prowler.pm"
      unless exists $ENV{PROWLER_ROOT};
}

package Prowler::Storage::Result::Record;
use DBIx::Class::Candy -components => ['InflateColumn::DateTime'];

table 'record';

column id => {

    data_type => 'int',
    is_auto_increment => 1,
};

column datetime => {

    data_type => 'datetime',
    size => 50,
};

column checksum => {

    data_type => 'varchar',
    size => 32,
};

column output => {

    data_type => 'TEXT'
};

primary_key 'id';

1;