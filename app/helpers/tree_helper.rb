module TreeHelper
  def link_to_leaf(leaf)
    return "nil" unless leaf
    if leaf.is_a?(Game)
      link_to_remote leaf.desc, :url => {:controller => 'game', :action => 'show', :id => leaf.id}, :update => 'right_div'
    elsif leaf.is_a?(Sports)
      link_to_remote leaf.desc, :url => {:controller => 'summary', :action => 'show', :id => 'Sports'}, :update => 'right_div'
    elsif leaf.is_a?(Sport)
      link_to_remote leaf.desc, :url => {:controller => 'summary', :action => 'show', :id => leaf.id}, :update => 'right_div'
    else
      link_to_remote leaf.desc, :url => {:controller => 'period', :action => 'show', :id => leaf.id}, :update => 'right_div'
    end
  end
  def has_children?(leaf) 
    leaf.respond_to?(:children) and leaf.children.size > 0
  end
  def leaf_class(leaf)
    leaf.current? ? "open" : "closed"
  rescue
    return "open"
  end
end
