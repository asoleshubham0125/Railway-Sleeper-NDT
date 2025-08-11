clear; clc; close all;

% === 1. Define Grid ===
Nx = 300;                 % Grid points in X (sleeper length)
Ny = 100;                 % Grid points in Y (sleeper height)
dx = 1e-3;                % Grid spacing = 1 mm
dy = 1e-3;
kgrid = kWaveGrid(Nx, dx, Ny, dy);

% === 2. Define Material (Concrete base) ===
medium.sound_speed = 4000 * ones(Nx, Ny);     % m/s (concrete)
medium.density = 2400 * ones(Nx, Ny);         % kg/m^3

% === Random Crack Generator ===
num_cracks = 6;             % Number of cracks
crack_thickness = 2;        % Thickness (grid points)
crack_min_len = 10;         % Minimum length of crack
crack_max_len = 40;         % Maximum length of crack

defect = zeros(Nx, Ny);     % Initialize defect map

for i = 1:num_cracks
    % Random orientation
    is_horizontal = rand > 0.5;

    % Random crack size
    crack_len = randi([crack_min_len, crack_max_len]);

    % Random position (ensure it fits inside grid)
    if is_horizontal
        x_start = randi([20, Nx - crack_thickness - 20]);
        y_start = randi([10, Ny - crack_len - 10]);
        defect(x_start:x_start+crack_thickness-1, y_start:y_start+crack_len-1) = 1;
    else
        x_start = randi([10, Nx - crack_len - 10]);
        y_start = randi([20, Ny - crack_thickness - 20]);
        defect(x_start:x_start+crack_len-1, y_start:y_start+crack_thickness-1) = 1;
    end
end

% === Apply Cracks to Medium ===
medium.sound_speed(defect == 1) = 1800;       % Air/honeycomb
medium.density(defect == 1) = 1200;

% === Visualize the Sound Speed Map ===
figure;
imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, medium.sound_speed);
xlabel('Y (mm)'); ylabel('X (mm)');
title('Railway Sleeper Sound Speed Map with Random Cracks');
colorbar; axis equal tight;

% === 3. Define Time Array ===
kgrid.t_array = makeTime(kgrid, max(medium.sound_speed(:)));

% === 4. Stronger Source (Wider pulse) ===
source.p_mask = zeros(Nx, Ny);
source.p_mask(10, round(Ny/2)-2:round(Ny/2)+2) = 1;   % 5-pixel wide source
source.p = 2e6 * toneBurst(1/kgrid.dt, 200e3, 7);     % 2 MHz amplitude, 7 cycles

% === 5. Sensor - Full bottom line ===
sensor.mask = zeros(Nx, Ny);
sensor.mask(end, :) = 1;                             % Bottom edge sensors
sensor.record = {'p'};                               % Record pressure

% === 6. Run Simulation ===
input_args = {'DataCast', 'single','PMLInside', false,'PlotPML', false};
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});

% === 7. Animate Wave Propagation ===
pressure = sensor_data.p;
figure;
for t = 1:10:size(pressure, 3)
    imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, pressure(:, :, t), [-0.5, 0.5]);
    title(['Wave Propagation in Railway Sleeper - Time = ' num2str(t)]);
    xlabel('Y (mm)'); ylabel('X (mm)');
    colormap(jet); colorbar;
    axis equal tight;
    drawnow;
end

% === 8. B-scan Plot (Echo Signals) ===
figure;
imagesc((1:size(sensor_data.p, 2)) * kgrid.dt * 1e6, 1:sum(sensor.mask(:)), sensor_data.p);
xlabel('Time (\mus)');
ylabel('Sensor Index');
title('Echo Signals from Concrete Sleeper (B-scan View)');
colorbar;
