requires 'perl', '5.010001';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'AnyEvent::MPRPC', '0.20';
    requires 'Data::MessagePack', '0.47';
};
