require 'jruby'
require 'irb'
require 'irb/completion'

if ARGV.empty?
  # default options, esp. useful for jrubyw
  ARGV << '--readline' << '--prompt' << 'inf-ruby'
end

import java.awt.Color
import java.awt.Font
import javax.swing.JFrame
import java.awt.EventQueue

# Try to find preferred font family, use otherwise -- err --  otherwise
def find_font(otherwise, style, size, *families)
  avail_families = java.awt.GraphicsEnvironment.local_graphics_environment.available_font_family_names
  fontname = families.find(proc {otherwise}) { |name| avail_families.include? name }
  Font.new(fontname, style, size)
end

text = javax.swing.JTextPane.new
text.font = find_font('Monospaced', Font::PLAIN, 14, 'Monaco', 'Andale Mono')
text.margin = java.awt.Insets.new(8,8,8,8)
text.caret_color = Color.new(0xa4, 0x00, 0x00)
text.background = Color.new(0xf2, 0xf2, 0xf2)
text.foreground = Color.new(0xa4, 0x00, 0x00)

pane = javax.swing.JScrollPane.new
pane.viewport_view = text
frame = JFrame.new('JRuby IRB Console (tab will autocomplete)')
frame.default_close_operation = JFrame::EXIT_ON_CLOSE if CLOSE_OPERATION;
frame.set_size(800, 700)
frame.content_pane.add(pane)
tar = org.jruby.demo.TextAreaReadline.new(text,
      " Welcome to the JRuby IRB Console [#{JRUBY_VERSION}] \n\n")
tar.hook_into_runtime_with_streams(JRuby.runtime)

# We need to show the frame on EDT,
# to avoid deadlocks.

# Once JRUBY-2449 is fixed,
# the code will me simplifed.
class FrameBringer
  include java.lang.Runnable
  def initialize(frame)
    @frame = frame
  end
  def run
    @frame.visible = true
	puts "You can start an Ooor connector by typing:\nrequire 'rubygems';require 'ooor';Ooor.new({:url => 'http://localhost:8069/xmlrpc', :database => 'mybase', :username => 'admin', :password => 'admin'})"
  end
end

EventQueue.invoke_later(FrameBringer.new(frame))

# From vanilla IRB
if __FILE__ == $0
  IRB.start(__FILE__)
else
  # check -e option
  if /^-e$/ =~ $0
    IRB.start(__FILE__)
  else
    IRB.setup(__FILE__)
  end
end
frame.dispose