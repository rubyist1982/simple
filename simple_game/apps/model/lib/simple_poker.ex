defmodule SimplePoker do
	@cards  for i <- 1..4, j<- 1..13, do: {i, j}
	@ten 10
	@ace 1
	@tian_gong [8,9]
	@ignore 0
	def init_cards, do: @cards
	# 洗牌
	def shuffle(cards), do: cards |> Enum.shuffle

	# 初始发牌
    def init_deal([a, b| t] = _cards), do: {:ok, [a, b], t}
	

	# 补单张
    def deal([card| left]), do: {:ok, card, left} 

    def single_point({_, p}) when p < @ten, do: p
    def single_point(_), do: @ten
    
    def normal_power(cards) do
    	sum = cards |> Enum.map( &single_point(&1) ) |> Enum.sum 
    	rem(sum, @ten)
    end
    # 牌力计算, 需参考是否开牌
    def power([_a, _b] = cards, is_open) do
		p = normal_power(cards)
		cond do
			p in @tian_gong and is_open -> {:tian_gong, p}
			true ->{:normal, p}
		end
    end

    def power(cards, false) do
    	cond do
    		is_flush_straight?(cards) -> {:flush_straight, @ignore}
    		is_three?(cards) -> {:three, @ignore}
    		is_flush?(cards) -> {:flush, @ignore}
    		is_straight?(cards) -> {:straight, @ignore}
    		true -> {:normal, normal_power(cards)}
		end	
    end

    # a 是否赢 b
    # 都是天公，比点数
    def win?({:tian_gong, p1}, {:tian_gong, p2}), do: p1 > p2
    # 天公比其他都大
    def win?({:tian_gong, _}, _), do: true
    def win?(_, {:tian_gong, _}), do: false

    # 非普通牌，通牌型一样大
    def win?({same, _}, {same, _}) when same != :normal, do: false
    # 同花顺比余下都大, 以下类推
    def win?({:flush_straight, _}, _), do: true
    def win?(_, {:flush_straight, _}), do: false
    def win?({:three, _}, _), do: true
    def win?(_, {:three, _}), do: false
    def win?({:flush, _}, _), do: true
    def win?(_, {:flush, _}), do: false
    def win?({:straight, _}, _), do: true
    def win?(_, {:straight, _}), do: false 
    # 普通牌需要比较点数
    def win?({:normal, p1}, {:normal, p2}), do: p1 > p2

    # 赢多少倍
    def multiply({:tian_gong, _}), do: 1
    def multiply({:flush_straight, _}), do: 16
    def multiply({:three, _}), do: 8
    def multiply({:flush, _}), do: 4
    def multiply({:straight, _}), do: 2
    def multiply({:normal, _}), do: 1


    def is_flush?([{s, _}, {s, _}, {s, _}]), do: true
    def is_flush?(_), do: false

    def is_straight?([{_, p1}, {_, p2}, {_, p3}]) do
    	[n1, n2, n3] = [p1, p2, p3] |> Enum.sort 
    	 cond do
    	 	n1 + 1 == n2 and n2 + 1 == n3 -> true
    	 	n1 == @ace and n2 + 1 == n3 -> true
    	 	n1 == @ace and n2 + 2  == n3 -> true	
    	 	true -> false
    	 end	
    end

    def is_three?([{_, p}, {_, p}, {_, p}]), do: true
    def is_three?([{_, p1}, {_, p2}, {_, p3}]) do
    	case [p1, p2, p3] |> Enum.sort do
    		[@ace, @ace, _] -> true
    		[@ace, n, n] -> true
    		_other -> false
    	end
    end

    def is_flush_straight?(cards), do: is_flush?(cards) and is_straight?(cards)

end

# SimplePoker.init_cards |> SimplePoker.shuffle |> IO.inspect
# SimplePoker.init_cards |> SimplePoker.init_deal(2) |> IO.inspect