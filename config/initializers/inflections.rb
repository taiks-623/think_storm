# config/initializers/inflections.rb

ActiveSupport::Inflector.inflections(:en) do |inflect|
  # "axis" の複数形を正しく "axes" に設定
  # デフォルトでは axis → axi と誤変換されるため明示的に指定
  inflect.irregular "axis", "axes"
end
