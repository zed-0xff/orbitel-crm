class LabellingFormBuilder
  def initialize *args
    @builder = ActionView::Helpers::FormBuilder.new(*args)
  end

  def method_missing mname, *args, &block
    if args.first.is_a?(Symbol) && arg=args.find{ |arg| arg.is_a?(Hash) && arg.key?(:label) }
      @builder.label(args.first, arg.delete(:label))
    else
      ''
    end +
    @builder.send(mname,*args, &block)
  end
end
