package Prowler::Model::Result::Records;
use DBIx::Class::Candy -components => ['InflateColumn::DateTime'];

table 'records';

column id => {

    data_type => 'int',
    is_auto_increment => 1,
};

column datetime => {

    data_type => 'datetime',
    size => 50,
};

column record => {

    data_type => 'varchar',
    size => 250,
    is_nullable => 1,
};

primary_key 'id';

1;