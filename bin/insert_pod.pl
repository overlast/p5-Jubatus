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
        while (my $subdir_path = $subdir->next) {
            if ((exists $subdir_path->{file}) && ($subdir_path->{file} =~ m|Client.pm|)){
                my $module_name =  $subdir_path->{dir}->{dirs}->[-1];
                my $module_path = join "/",@{$subdir_path->{dir}->{dirs}};
                print Dump $module_path;
                my $client_module_path = $module_path."/Client.pm";
                my $is_replace = &replace_true_to_pod($module_name, $client_module_path, $pod_tmpl_dir);

#                push @use_modules, "use ".$name_space.";";
#                my $get_client = &get_client_getter($name_space, $module_name);
#                push @get_clients, $get_client;
#                push @module_names, $module_name;
            }
        }
    }

=pod
    my $use_auto_gen_module = join "\n", @use_modules;
    my $get_client_from_auto_gen_module = join "\n", @get_clients;
    my $get_client_from_auto_gen_module_using_parameter = &get_client_getter_using_parameter(\@module_names);
    my $jubatus_pm_tmpl_path = $FindBin::Bin."/../jubatus_pm_tmpl";
    my $jubatus_pm_path = $FindBin::Bin."/../lib/Jubatus.pm";
    open my $in, "<:utf8", $jubatus_pm_tmpl_path;
    open my $out, ">:utf8", $jubatus_pm_path;
    while (my $line = <$in>) {
        if ($line =~ m|#### USE ALL AUTO GENERATE MODULES ####|) {
            print $out $use_auto_gen_module."\n";
        }
        elsif ($line =~ m|#### GET CLIENT FROM AUTO GENERATE MODULES ####|) {
            print $out $get_client_from_auto_gen_module."\n";
        }
        elsif ($line =~ m|#### GET CLIENT FROM AUTO GENERATE MODULES USING PARAMETER ####|) {
            print $out $get_client_from_auto_gen_module_using_parameter."\n";
        }
        else {
            print $out $line;
        }
    }
    close $out;
    close $in;
=cut

    return;
}

sub replace_true_to_pod {
    my ($module_name, $client_module_path, $pod_tmpl_dir) = @_;
    my $module_name_nc = $module_name;
    $module_name_nc =~ tr|[A-Z]|[a-z]|;

    my $tmp_client_module_path = $client_module_path.".tmp";
    my $pod_path = $pod_tmpl_dir."/".$module_name_nc.".pod";
    if (-f $pod_path) {
        open my $pod_in, "<:utf8", $pod_path;
        open my $module_in, "<:utf8", $client_module_path;
        open my $module_out, ">:utf8", $tmp_client_module_path;

        my @pod_lines = <$pod_in>;
        my $pod = join "", @pod_lines;

        while (my $line = <$module_in>) {
            if ($line =~ m|^1;$|) {
                print $module_out "1;\n";
                print $module_out $pod;
            }
            else {
                print $module_out $line;
            }
        }

        close $pod_in;
        close $module_in;
        close $module_out;

        system("mv $tmp_client_module_path $client_module_path");
    }
    return 1;
}
