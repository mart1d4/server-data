System.Math = {}

function System.Math.Round(value, decimal)
	if decimal then
		local power = 10 ^ decimal
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end
