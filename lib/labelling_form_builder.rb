class LabellingFormBuilder
  def initialize *args
    @builder = ActionView::Helpers::FormBuilder.new(*args)
  end

  def method_missing mname, *args, &block
    if args.first.is_a?(Symbol) && args[1].is_a?(Hash) && args[1].key?(:label)
      @builder.label(args.first, args[1].delete(:label))
    else
      ''
    end +
    @builder.send(mname,*args, &block)
  end
end
