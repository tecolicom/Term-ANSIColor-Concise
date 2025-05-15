requires 'perl', '5.014';

requires 'List::Util', '1.45';
requires 'Scalar::Util';
requires 'Graphics::ColorNames', 'v3';
requires 'Colouring::In', '0.27';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

