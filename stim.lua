
math.randomseed(os.time())

local function shuffleTable(t)
    local rand = math.random
    local iterations = #t
    local j
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

n_category = 5
n_songs_per_cat = 5
n_songs_from_each = 3
songs = {}
songs_to_play = {}

-- this function is called when the box is initialized
function initialize(box)
	io.write("initialize has been called\n");
	for i = 1, n_category do
	    songs[i] = {}
	    for j = 1, n_songs_per_cat do
		songs[i][j] = (i-1)*5 + j
	    end
	    shuffleTable(songs[i])
	    for k = 1, n_songs_from_each do
		table.insert(songs_to_play, songs[i][k])
	    end
	end
end

-- this function is called when the box is uninitialized
function uninitialize(box)
	io.write("uninitialize has been called\n")
end

function wait_until(box, time)
	while box:get_current_time() < time do
		box:sleep()
	end
end

function wait_for(box, duration)
	wait_until(box, box:get_current_time() + duration)
end

function process(box)
	io.write("process has been called\n")
	local playback_duration = 15
	local initial_wait = 20
	local interstimulus_duration = 15
	
	-- ilk bekleme
	wait_for(box, initial_wait)

	for i=1,#songs_to_play do
		box:send_stimulation(1, songs_to_play[i], box:get_current_time()+0.025, 0)
		wait_for(box, playback_duration)
		-- 0 sarkiyi durduralim anlamina gelsin
		box:send_stimulation(1, 0, box:get_current_time()+0.025, 0)
		wait_for(box, interstimulus_duration)
	end
	
	-- stop the scenario
	box:send_stimulation(1, OVTK_StimulationId_ExperimentStop, box:get_current_time()+0.025, 0)
end
