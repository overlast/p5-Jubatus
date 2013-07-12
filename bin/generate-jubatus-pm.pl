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
    my $dir = dir(File::Spec->rel2abs($FindBin::Bin).'/../lib/Jubatus/');
    my @use_modules;
    my @get_clients;
    while (my $dir_path = $dir->next) {
        my $subdir = dir($dir_path);
        while (my $subdir_path = $subdir->next) {
            if ((exists $subdir_path->{file}) && ($subdir_path->{file} =~ m|Client.pm|)){
                my $module_name =  $subdir_path->{dir}->{dirs}->[-1];
                my $name_space = "Jubatus::".$module_name."::Client";
                push @use_modules, "use ".$name_space.";";
                my $get_client = &get_client_getter($name_space, $module_name);
                push @get_clients, $get_client;
            }
        }
    }
    my $use_auto_gen_module = join "\n", @use_modules;
    my $get_client_from_auto_gen_module = join "\n", @get_clients;
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
        else {
            print $out $line;
        }
    }
    close $out;
    close $in;
    return;
}

sub get_client_getter {
    my ($name_space, $module_name) = @_;
    my $module_name_nc = $module_name;
    $module_name_nc =~ tr|[A-Z]|[a-z]|;
    my $tmpl = <<'__TMPL__';
sub get_==MODULE_NAME_NC==_client {
    my ($self, $host, $port) = @_;
    my $client = ==NAMESPACE==->new($host, $port);
    return $client;
}
__TMPL__
    $tmpl =~ s|==MODULE_NAME_NC==|$module_name_nc|;
    $tmpl =~ s|==NAMESPACE==|$name_space|;
    return $tmpl;
}
