function plotGlobe()

%% Textured 3D Earth example
%
% Ryan Gray
% 8 Sep 2004
% Revised 9 March 2006, 31 Jan 2006

%% Options

npanels = 72;   % Number of globe panels around the equator deg/panel = 360/npanels
alpha   = 1; % globe transparency level, 1 = opaque, through 0 = invisible

% Earth texture image
% Anything imread() will handle), but needs to be a 2:1 unprojected globe
% image.
% This is from NASA's Visible Earth site (http://visibleearth.nasa.gov/)
% The actual image link will likely move over time. This one is the 260KB
% version from this page: http://visibleearth.nasa.gov/view_rec.php?id=2430

image_file = 'land_ocean_ice_2048.jpg';

% Mean spherical earth

erad    = 6371008.7714; % equatorial radius (meters)
prad    = 6371008.7714; % polar radius (meters)

hold on;

%% Create wireframe globe

% Create a 3D meshgrid of the sphere points using the ellipsoid function

[x, y, z] = ellipsoid(0, 0, 0, erad, erad, prad, npanels);

globe = surf(x, y, -z, 'FaceColor', 'none', 'EdgeColor', 0.5*[1 1 1]);

%% Texturemap the globe

% Load Earth image for texture map

cdata = imread(image_file);

% Set image as color data (cdata) property, and set face color to indicate
% a texturemap, which Matlab expects to be in cdata. Turn off the mesh edges.

set(globe, 'FaceColor', 'texturemap', 'CData', cdata, 'FaceAlpha', alpha, 'EdgeColor', 'none');

