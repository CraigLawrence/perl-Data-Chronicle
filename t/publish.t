use strict;
use warnings;

use Date::Utility;
use Test::More;
use Data::Chronicle::Writer;
require Test::NoWarnings;

package t::InMemoryCache {
    use Moose;

    has cache => (is => 'ro', default => sub { {} });

    sub multi {}
    sub exec {}

    sub set {
        my ($self, $key, $value) = @_;
        $self->cache->{"set::$key"} = $value;
    }

    sub publish {
        my ($self, $key, $value) = @_;
        $self->cache->{"publish::$key"} = $value;
    }
};

my $data = { sample => 'data' };

subtest "enabled publish_on_set" => sub {
    my $cache = t::InMemoryCache->new;
    my $writer = Data::Chronicle::Writer->new(
        cache_writer   => $cache,
        publish_on_set => 1,
        ttl            => 86400
    );
    $writer->set('namespace', 'category', $data, Date::Utility->new, 0);
    ok $cache->cache->{"set::namespace::category"}, "data have been set";
    ok $cache->cache->{"publish::namespace::category"}, "data have been published";
    is $cache->cache->{"set::namespace::category"}, $cache->cache->{"publish::namespace::category"},
        "set and published data are identical";
};

subtest "disabled publish_on_set (default)" => sub {
    my $cache = t::InMemoryCache->new;
    my $writer = Data::Chronicle::Writer->new(
        cache_writer   => $cache,
        # publish_on_set => 0,             # defaults to false
        ttl            => 86400
    );
    $writer->set('namespace', 'category', $data, Date::Utility->new, 0);
    ok $cache->cache->{"set::namespace::category"}, "data have been set";
    ok !exists $cache->cache->{"publish::namespace::category"}, "data have NOT been published";
};


Test::NoWarnings::had_no_warnings();
done_testing;

