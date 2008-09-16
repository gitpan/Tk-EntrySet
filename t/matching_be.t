use strict;
use warnings;
#use lib './lib';

use Test::More qw/tests 18/;

my $mw;
BEGIN{use_ok('Tk');
      require_ok ('Tk::EntrySet');
      require_ok ('Tk::ChoicesSet');
  }
eval{$mw = MainWindow->new};

SKIP: {
    diag "Could not create MainWindow. Please check, if your X-server is running: $@\n" if ($@);
    skip "MainWindow instantiation failed: $@", 15 if ($@);
    
    my $mbe;
    
    $mw->geometry($mw->screenwidth
                  ."x"
                  .$mw->screenheight
                  ."+0+0");
    $mw->update;

    my $lv_set = [{value => 1, label => 'first'},
                  {value => 2, label => 'second'},
                  {value => 3, label => 'third'},
              ];
    
    my ($val, $first_entry);

                     
        eval{
            $mbe = $mw->MatchingBE()->pack;
        };
        isa_ok($mbe, 'Tk::MatchingBE', 'MatchingBE creation');
        $mbe->destroy;
        eval{
            $mbe = $mw->MatchingBE(-choices => [qw/foo bar baz/])->pack;
        };
        is_deeply([$mbe->cget('-choices')],[qw/foo bar baz/],
                  'getting/setting -choices');
        $mbe->destroy;
        eval{
            $mbe = $mw->MatchingBE(-labels_and_values => $lv_set)->pack;
        };
        ok(! $@, "instance creation with -labels_and_values given:$@");
        is_deeply($mbe->labels_and_values, $lv_set,
                  'get/set labels_and_values' );

      

    ### wrap these in TODO because of problems with eventGenerate
    ### and some wm...
  TODO: {
        local $TODO = 'tests that depend on eventGenerate might fail';
        $mbe->focus;
        $mbe->icursor('end');
        $mw->update;
        $mbe->focus;
        $mbe->eventGenerate('<Key-BackSpace>');
        $mw->update;
        $mbe->focus;
        $mbe->eventGenerate('<Key-Return>');
        $mbe->update;
        $val = $mbe->get_selected_value;
        is($val ,1 , 'selected first item per EventGen. get_selected_value');
        $val = $mbe->get_selected_label;
        is($val, 'first', 'selected first item get_selected_label');

    }

        $mbe->set_selected_value(2);
        $val = $mbe->get_selected_value;
        is($val, 2, 'set_selected_value');

        eval{$mbe->set_selected_value(42)};
        ok($@ , "can't set_selected_value to non existing value");
    my $val_var;
    $mbe->configure(-value_variable => \$val_var);
    $mbe->set_selected_value(1);
    is($val_var, 1, 'reading value_variable');

    $val_var = 2;
    is($mbe->get_selected_value, 2, 'writing value_variable');

    $mbe->destroy;
    eval{$val_var = 2};
    ok(! $@, 'value_variable has been untied during destroy');
    eval{
        $mbe = $mw->MatchingBE(
                              -value_variable => \$val_var,
                              -labels_and_values => $lv_set,
                               )->pack;
    };

    ok(! $@, 'instantiation with -labels_and_values and '
             .' value_variable set');
    is ($mbe->get_selected_value, 2,
         'value properly initialized during _value_variable tie'); 

    $lv_set = [{value => 1, label => 'first'},
               {value => 2, label => 'second'},
               {value => 1, label => 'third'},
              ];
    eval{$mbe->configure(-labels_and_values=> $lv_set)};
    ok($@ ,"won't accept -labels_and_values with non unique values");

    $mbe->configure(-choices=>[qw/foo bar baz/]);
    eval{$mbe->set_selected_value('foo')};
    ok($@ , "can't set_selected_value unless -labels_and_values"
            ." has been set.");
    

}#end SKIP
1;
