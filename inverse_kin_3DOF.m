function theta = inverse_kin_3DOF(x, y, z)
    %{
    Get Inverse Kinematic for OWI robot arm
    Assumptions:
    1. In front of robot (Joint 0)
    2. Forward Arm (Joint 1)
    3. Elbow Up (Joint 2)
    4. r1, r2, r3 is in cm
    %}
    
    r2 = 9;  % Length of the second segment in cm
    r3 = 25; % Length of the third segment in cm
    
    % Calculate the projection on the xy-plane
    r_xy = sqrt(x^2 + y^2);
    
    % Compute D using the law of cosines
    D = (r_xy^2 + z^2 - r2^2 - r3^2) / (2 * r2 * r3);
    
    % Check for valid D range to avoid imaginary values
    %if D < -1 || D > 1
    %    error('Target position is out of reach.');
    %end
    
    % Initialize theta array
    theta = zeros(1, 3);
    
    % Joint 0 angle (rotation in xy-plane)
    theta(1) = atan2(y, x);
    
    % Joint 2 angle (elbow angle)
    theta(3) = atan2(-sqrt(1 - D^2), D);
    
    % Joint 1 angle (shoulder angle)
    theta(2) = atan2(z, r_xy) - atan2(r3 * sin(theta(3)), r2 + r3 * cos(theta(3)));
    % Remap angles using linear mapping
    theta(1) = linear_map(theta(1), -pi/2, pi/2, 900, 400);
    theta(2) = linear_map(theta(2), 0, pi/2, 155, 510);
    theta(3) = linear_map(theta(3), -pi/2, pi/2, 200, 835);
end
function mapped_value = linear_map(value, in_min, in_max, out_min, out_max)
    % Perform linear mapping from [in_min, in_max] to [out_min, out_max]
    mapped_value = out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min);
end