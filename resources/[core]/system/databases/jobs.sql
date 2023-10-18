INSERT INTO
    `JobGrades` (job_name, grade, name, salary)
VALUES
    -- Unemployed
    ('Unemployed', 0, 'Unemployed', 600),

    -- Policeman
    ('Policeman', 0, 'Junior', 3300),
    ('Policeman', 1, 'Senior', 3500),
    ('Policeman', 2, 'Sergeant', 3700),
    ('Policeman', 3, 'Lieutenant', 3900),
    ('Policeman', 4, 'Captain', 4100),
    ('Policeman', 5, 'Deputy Chief', 4300),
    ('Policeman', 6, 'Chief', 4500),

    -- Firefighter
    ('Firefighter', 0, 'Junior', 3300),
    ('Firefighter', 1, 'Senior', 3500),
    ('Firefighter', 2, 'Sergeant', 3700),
    ('Firefighter', 3, 'Lieutenant', 3900),
    ('Firefighter', 4, 'Captain', 4100),
    ('Firefighter', 5, 'Deputy Chief', 4300),
    ('Firefighter', 6, 'Chief', 4500),

    -- Paramedic
    ('Paramedic', 0, 'Junior', 3100),
    ('Paramedic', 1, 'Senior', 3300),
    ('Paramedic', 2, 'Supervisor', 3500),
    ('Paramedic', 3, 'Paramedic-in-Charge', 3700),
    ('Paramedic', 4, 'Director of EMS', 3900),
    ('Paramedic', 5, 'EMS Chief', 4100),
    ('Paramedic', 6, 'EMS Commissioner', 4300),

    -- Car Dealer
    ('Car Dealer', 0, 'Junior', 3250),
    ('Car Dealer', 1, 'Sales Manager', 3450),
    ('Car Dealer', 2, 'Regional Manager', 3650),
    ('Car Dealer', 3, 'General Manager', 3850),
    ('Car Dealer', 4, 'Executive Director', 4050),
    ('Car Dealer', 5, 'CEO', 4250),
    ('Car Dealer', 6, 'Automotive Tycoon', 4450),

    -- Real Estate Agent
    ('Real Estate Agent', 0, 'Junior', 4000),
    ('Real Estate Agent', 1, 'Associate Agent', 4200),
    ('Real Estate Agent', 2, 'Sales Manager', 4400),
    ('Real Estate Agent', 3, 'Broker', 4600),
    ('Real Estate Agent', 4, 'Real Estate Director', 4800),
    ('Real Estate Agent', 5, 'Property Mogul', 5000),
    ('Real Estate Agent', 6, 'Real Estate Tycoon', 5200),
    
    -- Food Manufacturer
    ('Food Manufacturer', 0, 'Junior', 3800),
    ('Food Manufacturer', 1, 'Production Supervisor', 4000),
    ('Food Manufacturer', 2, 'Quality Control Manager', 4200),
    ('Food Manufacturer', 3, 'Plant Manager', 4400),
    ('Food Manufacturer', 4, 'Operations Director', 4600),
    ('Food Manufacturer', 5, 'Food Industry Mogul', 4800),
    ('Food Manufacturer', 6, 'Culinary Tycoon', 5000),

    -- Cashier
    ('Cashier', 0, 'Junior', 2650),
    ('Cashier', 1, 'Senior Cashier', 2800),
    ('Cashier', 2, 'Head Cashier', 2950),
    ('Cashier', 3, 'Cashier Supervisor', 3100),
    ('Cashier', 4, 'Frontend Manager', 3250),
    ('Cashier', 5, 'Retail Operations Director', 3400),
    ('Cashier', 6, 'Retail Tycoon', 3550),

    -- Lumberjack
    ('Lumberjack', 0, 'Junior', 3820),
    ('Lumberjack', 1, 'Experienced Lumberjack', 3950),
    ('Lumberjack', 2, 'Head Lumberjack', 4100),
    ('Lumberjack', 3, 'Lumberjack Supervisor', 4250),
    ('Lumberjack', 4, 'Lumber Mill Manager', 4400),
    ('Lumberjack', 5, 'Timber Operations Director', 4550),
    ('Lumberjack', 6, 'Timber Tycoon', 4700),

    -- Cab Driver
    ('Cab Driver', 0, 'Junior', 2580),
    ('Cab Driver', 1, 'Senior Cab Driver', 2800),
    ('Cab Driver', 2, 'Taxi Fleet Manager', 2950),
    ('Cab Driver', 3, 'Transportation Supervisor', 3100),
    ('Cab Driver', 4, 'Transportation Manager', 3250),
    ('Cab Driver', 5, 'City Transit Director', 3400),
    ('Cab Driver', 6, 'Transportation Mogul', 3550),

    -- Pilot (Airline Pilot)
    ('Pilot', 0, 'Junior', 12900),
    ('Pilot', 1, 'First Officer', 13500),
    ('Pilot', 2, 'Captain', 14000),
    ('Pilot', 3, 'Senior Captain', 14500),
    ('Pilot', 4, 'Chief Pilot', 15000),
    ('Pilot', 5, 'Director of Flight Operations', 15500),
    ('Pilot', 6, 'Airlines Tycoon', 16000),

    -- Soldier (Military)
    ('Soldier', 1, 'Sergeant', 3100),
    ('Soldier', 2, 'Lieutenant', 3300),
    ('Soldier', 3, 'Captain', 3500),
    ('Soldier', 4, 'Major', 3700),
    ('Soldier', 5, 'Colonel', 3900),
    ('Soldier', 6, 'General', 4100),

    -- Town Hall Employee (Government)
    ('Town Hall Employee', 1, 'Administrative Assistant', 1750),
    ('Town Hall Employee', 2, 'Department Manager', 1900),
    ('Town Hall Employee', 3, 'Assistant Town Clerk', 2050),
    ('Town Hall Employee', 4, 'Town Clerk', 2200),
    ('Town Hall Employee', 5, 'City Administrator', 2350),
    ('Town Hall Employee', 6, 'Mayor', 2500),

    -- Bartender (Hospitality)
    ('Bartender', 1, 'Senior Bartender', 3500),
    ('Bartender', 2, 'Bar Manager', 3700),
    ('Bartender', 3, 'Mixology Master', 3900),
    ('Bartender', 4, 'Nightclub Owner', 4100),


    -- Delivery Driver (Logistics)
    ('Delivery Driver', 1, 'Route Supervisor', 3300),
    ('Delivery Driver', 2, 'Logistics Manager', 3500),
    ('Delivery Driver', 3, 'Delivery Fleet Owner', 3700),
    ('Delivery Driver', 4, 'Shipping Magnate', 3900),
    ('Delivery Driver', 5, 'Transportation Mogul', 4100),

    -- Mechanic (Auto Industry)
    ('Mechanic', 1, 'Certified Mechanic', 3500),
    ('Mechanic', 2, 'Garage Supervisor', 3700),
    ('Mechanic', 3, 'Auto Repair Shop Owner', 3900),
    ('Mechanic', 4, 'Auto Industry Tycoon', 4100),
    ('Mechanic', 5, 'Automotive Mogul', 4300);
