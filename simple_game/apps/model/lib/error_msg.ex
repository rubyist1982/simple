defmodule ErrorMsg do
    @msgs %{
		player_not_enough: "player_not_enough",
		not_ready_state: "not_ready_state",
		can_not_dismiss_when_playing: "can_not_dismiss_when_playing",
		just_creator_can_start: "just_creator_can_start",
		just_creator_can_dismiss: "just_creator_can_dismiss",
		can_not_join_when_playing: "can_not_join_when_playing",
		player_num_limit: "player_num_limit",
		repeated_join: "repeated_join",
		can_not_quit_when_playing: "can_not_quit_when_playing",
		can_not_quit_when_creator: "can_not_quit_when_creator",
		not_makeup_state: "not_makeup_state",
		can_not_make_up_when_open: "can_not_make_up_when_open",
		can_not_make_up_when_full: "can_not_make_up_when_full",
		just_tian_gong_can_open: "just_tian_gong_can_open",
		repeated_open: "repeated_open",
		not_open_state: "not_open_state",
		not_in_table: "not_in_table",
		makeup_op_done: "makeup_op_done",
		open_op_done: "open_op_done",
		cant_not_make_up_when_open: "cant_not_make_up_when_open"
	}

	for {tag, text} <- @msgs do
		def unquote(tag)() do
			unquote text
		end
	end


end