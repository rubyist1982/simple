defmodule SimplePokerTest do
  use ExUnit.Case
  doctest SimplePoker

  setup do
  	%{
  		s_ace: {1,1},   # 黑桃A
  		h_ace:  {2, 1}, # 红桃A,
  		c_ace: {3, 1},  # 梅花A
  		s_two: {1, 2},  # 黑桃2
  		h_two: {2, 2},  # 红桃2
  		c_two: {3, 2},  # 梅花2
  		s_three: {1, 3},  # 黑桃3
  		h_three: {2, 3}, # 红桃3
  		s_four: {1, 4},  # 黑桃4
  		h_four: {2, 4},  # 红桃4
  		s_five: {1, 5}, # 黑桃5
  		s_eight: {1, 8}, # 黑桃8
  		s_nine: {1, 9}, # 黑桃9
  		s_ten: {1, 10}, # 黑桃10
  		s_jack: {1, 11}

  	}
  end  


  test "同花: 黑桃A，黑桃2, 黑桃3 ", cards do
  	flush_cards = [cards.s_ace, cards.s_two, cards.s_three]
  	assert SimplePoker.is_flush?(flush_cards)
  end

  test "非同花: 黑桃A, 红桃A, 黑桃2 ", cards do
  	not_flush_cards = [cards.s_ace, cards.h_ace, cards.s_two]
  	refute SimplePoker.is_flush?(not_flush_cards) 
  end

  test "三条: 普通", cards do
  	normal_three = [cards.s_two, cards.h_two, cards.c_two]
  	assert SimplePoker.is_three?(normal_three)
  end

  test "三条：1张A + 1对 ", cards do
    one_ace_and_one_pair = [cards.s_two, cards.h_two, cards.s_ace]
    assert SimplePoker.is_three?(one_ace_and_one_pair)
  end

  test "三条: 2张A + 1张2 ", cards do
    two_ace_and_one = [cards.s_ace, cards.h_ace, cards.s_two]	
    assert SimplePoker.is_three?(two_ace_and_one)
  end

  test "非三条: A, 2, 3", cards do
  	not_three = [cards.s_ace, cards.s_two, cards.s_three]
  	refute SimplePoker.is_three?(not_three)
  end

  test "顺子： 普通 黑桃2， 黑桃3， 红桃4", cards do
  	normal_straight = [cards.s_two, cards.s_three, cards.h_four]
  	assert SimplePoker.is_straight?(normal_straight)
  end

  test "顺子： 普通 黑桃A, 黑桃2， 红桃3", cards do
  	one_ace_normal_straight = [cards.s_ace, cards.s_two, cards.h_three]
  	assert SimplePoker.is_straight?(one_ace_normal_straight)
  end

  test "顺子: 普通 黑桃A, 黑桃2， 红桃4", cards do
  	one_ace_normal_straight = [cards.s_ace, cards.s_two, cards.h_four]
  	assert SimplePoker.is_straight?(one_ace_normal_straight)
  end

  test "非顺子: 黑桃A， 黑桃2, 红桃2", cards do
  	not_straight = [cards.s_ace, cards.s_two, cards.h_two]
  	refute SimplePoker.is_straight?(not_straight)
  end

  test "同花顺: 普通", cards do
  	normal_flush_straight = [cards.s_two, cards.s_three, cards.s_four]
  	assert SimplePoker.is_flush_straight?(normal_flush_straight)	
  end

  test "普通三张", cards do
  	normal = [cards.s_two, cards.s_two, cards.h_three]
  	assert {:normal, _} = SimplePoker.power(normal, false)
  end

  test "天公9点", cards do
  	assert {:tian_gong, 9} = [cards.s_ace, cards.s_eight] |> SimplePoker.power(true) 
  	assert {:tian_gong, 9} = [cards.s_four, cards.s_five] |> SimplePoker.power(true)
  end

  test "普通9点", cards do
  	assert {:normal, 9} = [cards.s_ace, cards.s_eight] |> SimplePoker.power(false)
  end

  test "single_point", cards do
  	 assert  1 == cards.s_ace |> SimplePoker.single_point
  	 assert 10 == cards.s_ten |> SimplePoker.single_point 
  	 assert 10 == cards.s_jack |> SimplePoker.single_point
  end
  
  test "win?" do
  	tian_gong_9 = {:tian_gong, 9}
  	tian_gong_8 = {:tian_gong, 8}
  	flush_straight = {:flush_straight, 0}
    three = {:three, 0}
    flush = {:flush, 0}
    straight = {:straight, 0}
    normal_9 = {:normal, 9}
    normal_8 = {:normal, 8}

    assert SimplePoker.win?(tian_gong_9, tian_gong_8) 
    refute SimplePoker.win?(tian_gong_9, tian_gong_9)
    refute SimplePoker.win?(tian_gong_8, tian_gong_9)
    assert SimplePoker.win?(tian_gong_9, flush_straight)
    refute SimplePoker.win?(flush_straight, tian_gong_9)

    refute SimplePoker.win?(flush_straight, flush_straight)
    assert SimplePoker.win?(flush_straight, three)
    refute SimplePoker.win?(three, flush_straight)

    assert SimplePoker.win?(three, flush)
    refute SimplePoker.win?(flush, three)

    assert SimplePoker.win?(flush, straight)
    refute SimplePoker.win?(straight, flush)

    assert SimplePoker.win?(straight, normal_9)
    refute SimplePoker.win?(normal_9, straight)

    assert SimplePoker.win?(normal_9, normal_8)
    refute SimplePoker.win?(normal_9, normal_9)
    refute SimplePoker.win?(normal_8, normal_9)
  end

end