use strict;
use warnings;


use Test::More qw/tests 15/;

my $mw;
BEGIN{use_ok('Tk');
      require_ok ('Tk::EntrySet');
      require_ok ('Tk::ChoicesSet');
  }
eval{$mw = MainWindow->new};

SKIP: {
    diag "Could not create MainWindow. Please check, if your X-server is running: $@\n" if ($@);
    skip "MainWindow instantiation failed: $@", 12 if ($@);
    
    my $mbe;
    eval{
        $mbe = $mw->ChoicesSet->pack(-fill   => 'both',
                                     -expand => 1);
        $mw->update;
    };

    isa_ok ($mbe , 'Tk::ChoicesSet', 'Tk::ChoicesSet instance creation');
    my ($labels, $labels_and_values);
    eval{
        $mbe->choices([qw/foo bar baz/]);
        $labels  = $mbe->choices;
        $mw->update;
        
    };
    is_deeply($labels, [qw/foo bar baz/], 'Setting choices');
    my $lv_set = [{value => 1, label => 'first'},
                  {value => 2, label => 'second'},
                  {value => 3, label => 'third'},
              ];
    eval{
        $mbe->labels_and_values( $lv_set );
        $labels  = $mbe->get_labels;
        $labels_and_values = $mbe->labels_and_values;
        $mw->update;
    };
    is_deeply ($labels_and_values, $lv_set,
               'Setting/getting labels_and_values');
    is_deeply ($labels, [qw/first second third/], 'getting labels');

    my $sel;
    my $valuelist;
    eval{
        $mbe->valuelist_variable( \$sel );
        $sel = [1];
        $valuelist = $mbe->valuelist;
        $mw->update;
    };
    is_deeply($valuelist, [1], '-valuelist_variable tie');
    eval{
        $mbe->valuelist([1,2]);
        $mw->update;
        $valuelist = $sel;
    };
    is_deeply($valuelist, [1,2], 'read tied variable');
    eval{
        $sel = [1,3];
        $mw->update;
        $valuelist = $mbe->valuelist;
    };
    is_deeply($valuelist, [1,3], 'write tied variable');
    $mw->update;
    
    ### Invoke some methods of MatchingEE ###
    my ($val, $first_entry);
    ### wrap these in TODO because of problems with eventGenerate
    ### and some wm...
  TODO: {
        eval{
            $first_entry = $mbe->{_EntrySet}{entries}[0];
            $first_entry->focus;
            $mw->update;
            $first_entry->icursor('end');
            $mw->update;
            $first_entry->eventGenerate('<Key-BackSpace>');
            $first_entry->focus;
            $mw->update;
            $first_entry->eventGenerate('<Key-Return>');
            $mw->update;
            $val = $first_entry->get_selected_value;
        };
        ok (! $@, 'Additional MBE tests');    
        is ($val, 'first', 'MBE get_selected_value');
        eval{
            $first_entry->focus;
            $mw->update;
            $first_entry->icursor(2);
            $mw->update;
            $first_entry->eventGenerate('<Key-BackSpace>');
            $first_entry->focus;
            $mw->update;
            $first_entry->eventGenerate('<Key-Return>');
            $mw->update;
            $val = $first_entry->get_selected_value;
        };
        is ($val, undef, 'No Match: MBE value set to undef');

    }                           ###end TODO
    
    ### Some tests for Tk::EntrySet ###

    my ($es, $list);
    eval{
        $es = $mw->EntrySet()->pack;
        $mw->update;
    };
    isa_ok($es, 'Tk::EntrySet', 'Tk::EntrySet instance creation');
    eval{
        $es->valuelist([qw/foo bar baz/]);
        $list = $es->valuelist;
        $mw->update;
    };
    is_deeply($list, [qw/foo bar baz/], 'get/set EntrySet valuelist');;
    
}
