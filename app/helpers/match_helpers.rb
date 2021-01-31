module App
  module MatchHelpers
    def match_source
      "#{buffer.name}:#{@expr.line}"
    end

    def match_source_href
      "file://#{buffer.name}"
    end

    def match
      line = @expr.source_line
      cols = @expr.column_range
      pre = line[0...cols.begin]
      m = line[cols]
      post = line[cols.end..-1]
      [pre, m, post]
    end

    def buffer
      @expr.source_buffer
    end
  end
end

helpers App::MatchHelpers
