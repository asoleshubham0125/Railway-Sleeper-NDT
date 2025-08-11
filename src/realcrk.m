clear; clc; close all;

% === 1. Define Grid ===
Nx = 300; Ny = 100;               % Grid size (X: length, Y: height of sleeper)
dx = 1e-3; dy = 1e-3;             % Grid spacing = 1 mm
kgrid = kWaveGrid(Nx, dx, Ny, dy);

% === 2. Define Material (Concrete) ===
medium.sound_speed = 4000 * ones(Nx, Ny);     % Speed of sound in concrete (m/s)
medium.density = 2400 * ones(Nx, Ny);         % Density of concrete (kg/m^3)

% === 3. Realistic Crack Generator ===
num_cracks = 6;                   % Number of cracks
crack_min_len = 10;               % Minimum crack length
crack_max_len = 40;               % Maximum crack length
defect = zeros(Nx, Ny);           % Crack mask

for i = 1:num_cracks
    x0 = randi([20, Nx - 20]);
    y0 = randi([20, Ny - 20]);
    theta = rand * 2 * pi;        % Random orientation
    L = randi([crack_min_len, crack_max_len]);

    for l = 0:L-1
        dx_crack = round(l * cos(theta) + randn);
        dy_crack = round(l * sin(theta) + randn);
        x = x0 + dx_crack;
        y = y0 + dy_crack;

        if x > 1 && x <= Nx-1 && y > 1 && y <= Ny-1
            defect(x-1:x+1, y-1:y+1) = 1;  % Thicken crack to 3x3 area
        end
    end
end

% === 4. Apply Cracks to Medium Properties ===
medium.sound_speed(defect == 1) = 1500;   % Cracks (air-like)
medium.density(defect == 1) = 500;

% === 5. Time Array ===
kgrid.t_array = makeTime(kgrid, max(medium.sound_speed(:)));

% === 6. Define Source (Wider Pulse) ===
source.p_mask = zeros(Nx, Ny);
source.p_mask(10, round(Ny/2)-2 : round(Ny/2)+2) = 1;   % 5-pixel wide line source
source.p = 2e6 * toneBurst(1/kgrid.dt, 200e3, 7);       % 2 MHz, 7 cycles

% === 7. Define Sensor (Bottom Edge) ===
sensor.mask = zeros(Nx, Ny);
sensor.mask(end, :) = 1;            % Sensors along bottom edge
sensor.record = {'p'};              % Record pressure

% === 8. Run the Simulation ===
input_args = {'DataCast', 'single', 'PMLInside', false, 'PlotPML', false};
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});
pressure = sensor_data.p;

% === 9. Animate Wave Propagation ===
figure('Name', 'Wave Propagation Animation');
for t = 1:10:size(pressure, 3)
    imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, pressure(:, :, t), [-0.5, 0.5]);
    title(['Wave Propagation - Time Step = ' num2str(t)]);
    xlabel('Y (mm)'); ylabel('X (mm)');
    colormap(jet); colorbar;
    axis equal tight;
    drawnow;
end

% === 10. Unified Visualization in One Figure ===
figure('Name', 'Railway Sleeper Simulation Summary', 'Color', 'w', 'Position', [100 100 1200 800]);

% --- Subplot 1: Sound Speed Map with Cracks ---
subplot(3,2,1);
imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, medium.sound_speed);
xlabel('Y (mm)'); ylabel('X (mm)');
title('Sound Speed Map with Realistic Cracks');
colorbar; axis equal tight;

% --- Subplot 2: Final Wave Snapshot ---
subplot(3,2,2);
imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, pressure(:, :, end), [-0.5, 0.5]);
xlabel('Y (mm)'); ylabel('X (mm)');
title('Final Wave Snapshot');
colormap(jet); colorbar;
axis equal tight;

% --- Subplot 3: B-scan Echo Signals ---
subplot(3,1,2);
imagesc((1:size(sensor_data.p, 2)) * kgrid.dt * 1e6, 1:sum(sensor.mask(:)), sensor_data.p);
xlabel('Time (\mus)');
ylabel('Sensor Index');
title('B-scan Echo Signals');
colorbar;

% === A-scan Plot (Intensity vs Time) ===

center_sensor_index = round(Ny / 2);                 % 50th column (middle sensor on bottom edge)
intensity_signal = sensor_data.p(center_sensor_index, :);  % Extract 1D signal from that sensor
subplot(3,1,3);
plot(kgrid.t_array * 1e6, intensity_signal, 'b', 'LineWidth', 1.5);
xlabel('Time (\mus)');
ylabel('Pressure Amplitude');
title('A-scan at Center Sensor (Bottom Edge)');
grid on;

