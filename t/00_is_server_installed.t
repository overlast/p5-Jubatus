use strict;
use Test::More tests => 6;

my @server_name_suffix = (
    "regression",
    "recommender",
    "classifier",
    "stat",
    "graph",
    "anomaly",
);
foreach my $suffix (@server_name_suffix) {
    my $server_name = "juba".$suffix;
    my $is_there = system("which $server_name"); # there => 0
    is($is_there, 0, "is $server_name there ?");
}



=pod

use Test::More tests => 4;

use Algorithm::RankAggregate;

my @case_00 = (279.8, 188.8, 84.8, 41.8,  20.1);
my @ans_00 = (1, 2, 3, 4, 5);

my @case_01 = (-24.8, -18.2, -8.0, -3.4, -18.0);
my @ans_01 = (5, 4, 2, 1, 3);

my @case_02 = (-17.7,  13.0, -5.7, -2.4,  12.9);
my @ans_02 = (5, 1, 4, 3, 2);

my @case_03 = (-17.7,  13.0, -2.4, -2.4,  12.9);
my @ans_03 = (5, 1, 3, 3, 2);


my $bc = Algorithm::RankAggregate->new();

is_deeply($bc->get_ranked_list(\@case_00), \@ans_00);
is_deeply($bc->get_ranked_list(\@case_01), \@ans_01);
is_deeply($bc->get_ranked_list(\@case_02), \@ans_02);
is_deeply($bc->get_ranked_list(\@case_03), \@ans_03);




#!/usr/bin/env python

import unittest

import json
from math import sqrt
import msgpackrpc

from jubatus.recommender.client import recommender
from jubatus.recommender.types  import *
from jubatus_test.test_util import TestUtil

host = "127.0.0.1"
port = 21003
timeout = 10

class RecommenderTest(unittest.TestCase):
  def setUp(self):
    self.config = {
        "method": "inverted_index",
        "converter": {
            "string_filter_types": {},
            "string_filter_rules": [],
            "num_filter_types": {},
            "num_filter_rules": [],
            "string_types": {},
            "string_rules": [{"key": "*", "type": "str",  "sample_weight": "bin", "global_weight": "bin"}],
            "num_types": {},
            "num_rules": [{"key": "*", "type": "num"}]
        },
        "parameter": {}
    }

    TestUtil.write_file('config_recommender.json', json.dumps(self.config))
    self.srv = TestUtil.fork_process('recommender', port, 'config_recommender.json')
    self.cli = recommender(host, port)

  def tearDown(self):
    TestUtil.kill_process(self.srv)

  def test_get_client(self):
    self.assertIsInstance(self.cli.get_client(), msgpackrpc.client.Client)

  def test_get_config(self):
    config = self.cli.get_config("name")
    self.assertEqual(json.dumps(json.loads(config), sort_keys=True), json.dumps(self.config, sort_keys=True))

  def test_complete_row(self):
    self.cli.clear_row("name", "complete_row")
    string_values = [("key1", "val1"), ("key2", "val2")]
    num_values = [("key1", 1.0), ("key2", 2.0)]
    d = datum(string_values, num_values)
    self.cli.update_row("name", "complete_row", d)
    d1 = self.cli.complete_row_from_id("name", "complete_row")
    d2 = self.cli.complete_row_from_datum("name", d)

  def test_similar_row(self):
    self.cli.clear_row("name", "similar_row")
    string_values = [("key1", "val1"), ("key2", "val2")]
    num_values = [("key1", 1.0), ("key2", 2.0)]
    d = datum(string_values, num_values)
    self.cli.update_row("name", "similar_row", d)
    s1 = self.cli.similar_row_from_id("name", "similar_row", 10)
    s2 = self.cli.similar_row_from_datum("name", d, 10)

  def test_decode_row(self):
    self.cli.clear_row("name", "decode_row")
    string_values = [("key1", "val1"), ("key2", "val2")]
    num_values = [("key1", 1.0), ("key2", 2.0)]
    d = datum(string_values, num_values)
    self.cli.update_row("name", "decode_row", d)
    decoded_row = self.cli.decode_row("name", "decode_row")
    self.assertEqual(d.string_values, decoded_row.string_values)
    self.assertEqual(d.num_values, decoded_row.num_values)

  def test_get_row(self):
    self.cli.clear("name")
    string_values = [("key1", "val1"), ("key2", "val2")]
    num_values = [("key1", 1.0), ("key2", 2.0)]
    d = datum(string_values, num_values)
    self.cli.update_row("name", "get_row", d)
    row_names = self.cli.get_all_rows("name")
    self.assertEqual(row_names, ["get_row"])

  def test_clear(self):
    self.cli.clear("name")

  def test_calcs(self):
    string_values = [("key1", "val1"), ("key2", "val2")]
    num_values = [("key1", 1.0), ("key2", 2.0)]
    d = datum(string_values, num_values)
    self.assertAlmostEqual(self.cli.calc_similarity("name", d, d), 1, 6)
    self.assertAlmostEqual(self.cli.calc_l2norm("name", d), sqrt(1*1 + 1*1+ 1*1 + 2*2), 6)

  def test_clear(self):
    self.cli.clear("name")

  def test_save(self):
    self.assertEqual(self.cli.save("name", "recommender.save_test.model"), True)

  def test_load(self):
    model_name = "recommender.load_test.model"
    self.cli.save("name", model_name)
    self.assertEqual(self.cli.load("name", model_name), True)

  def test_get_status(self):
    self.cli.get_status("name")



if __name__ == '__main__':
  test_suite = unittest.TestLoader().loadTestsFromTestCase(RecommenderTest)
  unittest.TextTestRunner().run(test_suite)


=cut
