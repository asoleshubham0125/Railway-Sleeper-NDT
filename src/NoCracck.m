clear; clc; close all;

% === 1. Define Grid ===
Nx = 300; Ny = 100;
dx = 1e-3; dy = 1e-3;
kgrid = kWaveGrid(Nx, dx, Ny, dy);

% === 2. Define Material (Solid Concrete, No Cracks) ===
medium.sound_speed = 4000 * ones(Nx, Ny);     % Solid concrete
medium.density = 2400 * ones(Nx, Ny);         % No defects

% === 3. Time Array ===
kgrid.t_array = makeTime(kgrid, max(medium.sound_speed(:)));

% === 4. Define Source (Wider Pulse) ===
source.p_mask = zeros(Nx, Ny);
source.p_mask(10, round(Ny/2)-2 : round(Ny/2)+2) = 1;   % 5-pixel wide line source
source.p = 2e6 * toneBurst(1/kgrid.dt, 200e3, 7);       % 2 MHz, 7 cycles

% === 5. Define Sensor (Bottom Edge) ===
sensor.mask = zeros(Nx, Ny);
sensor.mask(end, :) = 1;
sensor.record = {'p'};

% === 6. Run the Simulation ===
input_args = {'DataCast', 'single', 'PMLInside', false, 'PlotPML', false};
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});
pressure = sensor_data.p;

% === 7. Animate Wave Propagation ===
figure('Name', 'Wave Propagation Animation');
for t = 1:10:size(pressure, 3)
    imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, pressure(:, :, t), [-0.5, 0.5]);
    title(['Wave Propagation - Time Step = ' num2str(t)]);
    xlabel('Y (mm)'); ylabel('X (mm)');
    colormap(jet); colorbar;
    axis equal tight;
    drawnow;
end

% === 8. Unified Visualization in One Figure ===
figure('Name', 'Railway Sleeper Simulation Summary (No Cracks)', 'Color', 'w', 'Position', [100 100 1200 800]);

% --- Subplot 1: Sound Speed Map (No Cracks) ---
subplot(3,2,1);
imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, medium.sound_speed);
xlabel('Y (mm)'); ylabel('X (mm)');
title('Sound Speed Map (No Cracks)');
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

% --- Subplot 4: A-scan (Center Sensor) ---
center_sensor_index = round(Ny / 2);
intensity_signal = sensor_data.p(center_sensor_index, :);
subplot(3,1,3);
plot(kgrid.t_array * 1e6, intensity_signal, 'b', 'LineWidth', 1.5);
xlabel('Time (\mus)');
ylabel('Pressure Amplitude');
title('A-scan at Center Sensor (Bottom Edge)');
grid on;
