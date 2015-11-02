function utility_functions_spec

K_SOME_SCALAR = festwert(1.3);
K_SOME_VECTOR = festwerteblock([1.0 2.0 3.0]);
K_SOME_MATRIX = festwerteblock([1 2; 3 4]);
K_SOME_SSV    = stuetzstellenverteilung([0 1 2 10]);
K_SOME_KL     = kennlinie([0 1 2 3], [10 20 30 40]);
K_SOME_KF     = kennfeld([0 1], [1 2 3], [10 20 30; 40 50 60]);

% Festwert
expect(all(size(K_SOME_SCALAR) == 1));
expect(K_SOME_SCALAR == 1.3);

% Festwerteblock
expect(all(size(K_SOME_VECTOR) == [1 3]));
expect(all(K_SOME_VECTOR == [1.0 2.0 3.0]));
expect(all(size(K_SOME_MATRIX) == [2 2]));
expect(all(all(K_SOME_MATRIX == [1 2; 3 4])));

% Stuetzstellenverteilung
expect(isfield(K_SOME_SSV, 'x'));
expect(all(K_SOME_SSV.x == [0 1 2 10]));

% Kennlinie
expect(isfield(K_SOME_KL, 'x'));
expect(isfield(K_SOME_KL, 'y'));
expect(all(K_SOME_KL.x == [0 1 2 3]));
expect(all(K_SOME_KL.y == [10 20 30 40]));

% Kennfeld
expect(isfield(K_SOME_KF, 'x'));
expect(isfield(K_SOME_KF, 'y'));
expect(isfield(K_SOME_KF, 'y'));
expect(all(K_SOME_KF.x == [0 1]));
expect(all(K_SOME_KF.y == [1 2 3 ]));
expect(all(all(K_SOME_KF.z == [10 20 30; 40 50 60])));

