defmodule ErrorMsg do
    @msgs %{
		player_not_enough: "player_not_enough",
		can_not_start_when_playing: "can_not_start_when_playing",
		can_not_dismiss_when_playing: "can_not_dismiss_when_playing",
		just_creator_can_start: "just_creator_can_start",
		just_creator_can_dismiss: "just_creator_can_dismiss",
		can_not_join_when_playing: "can_not_join_when_playing",
		repeated_join: "repeated_join",
		can_not_quit_when_playing: "can_not_quit_when_playing",
		can_not_quit_when_creator: "can_not_quit_when_creator",
		can_not_make_up_when_not_playing: "can_not_makeup_when_not_playing",
		can_not_make_up_when_open: "can_not_make_up_when_open",
		can_not_make_up_when_full: "can_not_make_up_when_full",
		just_tian_gong_can_open: "just_tian_gong_can_open",
		repeated_open: "repeated_open",
		cant_not_open_when_ready: "cant_not_open_when_ready"
	}

	for {tag, text} <- @msgs do
		def unquote(tag)() do
			unquote text
		end
	end


end