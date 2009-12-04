module SearchHelper
  # case-independent highlight
  def highlight_nocase text, phrases, *args
    phrases = Array(phrases)
    dtext = nil
    phrases.each do |phrase|
      next if text[phrase] # found w/o any case tweaks
      dtext ||= text.mb_chars.downcase.to_s
      dphrase = phrase.mb_chars.downcase.to_s
      if idx = dtext.mb_chars.index(dphrase)
        phrases << text.mb_chars[idx..(idx+phrase.mb_chars.size-1)].to_s
      end
    end
    highlight(text, phrases, *args)
  end
end
