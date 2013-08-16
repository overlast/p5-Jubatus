#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use File::Spec;
use FindBin;
use Path::Class qw/dir/;
use YAML;

&main();

sub main {
    my $base_dir = File::Spec->rel2abs($FindBin::Bin);
    my $dir = dir($base_dir.'/../lib/Jubatus/');
    my $pod_tmpl_dir = $base_dir.'/../tmpl/';
    my @use_modules;
    my @get_clients;
    my @module_names;
    while (my $dir_path = $dir->next) {
        my $subdir = dir($dir_path);
        my $dir = $subdir->{dirs}->[-1];
        next if ($dir =~ m|^.+\.pm$|);
        while (my $subdir_path = $subdir->next) {
            if ((exists $subdir_path->{file}) && ($subdir_path->{file} =~ m|Client.pm|)){
                my $module_name =  $subdir_path->{dir}->{dirs}->[-1];
                my $module_path = join "/",@{$subdir_path->{dir}->{dirs}};
                {
                    my $pod_type = "client";
                    my $client_module_path = $module_path."/Client.pm";
                    my $is_replace = &replace_true_to_pod($module_name, $client_module_path, $pod_tmpl_dir, $pod_type);
                }
                {
                    my $pod_type = "types";
                    my $client_module_path = $module_path."/Types.pm";
                    my $is_replace = &replace_true_to_pod($module_name, $client_module_path, $pod_tmpl_dir, $pod_type);
                }
            }
        }
    }
    return;
}

sub replace_true_to_pod {
    my ($module_name, $client_module_path, $pod_tmpl_dir, $pod_types) = @_;
    my $module_name_nc = $module_name;
    $module_name_nc =~ tr|[A-Z]|[a-z]|;
    my $is_replaced = 0;
    my $tmp_client_module_path = $client_module_path.".tmp";
    my $pod_path = $pod_tmpl_dir."/".$module_name_nc."_".$pod_types.".pod";
    if (-f $pod_path) {
        open my $pod_in, "<:utf8", $pod_path;
        open my $module_in, "<:utf8", $client_module_path;
        open my $module_out, ">:utf8", $tmp_client_module_path;

        my @pod_lines = <$pod_in>;
        my $pod = join "", @pod_lines;
        my $is_package = 0;
        while (my $line = <$module_in>) {
            if (($is_package) && ($line =~ m|^1;$|)) {
                print $module_out "1;\n";
                print $module_out $pod;
            }
            else {
                print $module_out $line;
            }
            if ($line =~ m|package Jubatus::.+::Client;|) {
                $is_package = 1;
            }
            elsif ($line =~ m|package Jubatus::.+::Types;|) {
                $is_package = 1;
            }
        }

        close $pod_in;
        close $module_in;
        close $module_out;

        my $is_mv = system("mv $tmp_client_module_path $client_module_path");
        $is_replaced = 1 if (0 == $is_mv);
    } else {
    }
    return $is_replaced;
}
