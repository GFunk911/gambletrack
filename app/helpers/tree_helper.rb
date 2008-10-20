module TreeHelper
  def link_to_leaf(leaf)
    return "nil" unless leaf
    if leaf.is_a?(Game)
      link_to leaf.desc, :controller => 'game', :action => 'show', :id => leaf.id
    elsif leaf.is_a?(Sports)
      link_to leaf.desc, :controller => 'summary', :action => 'show', :id => 'Sports'
    elsif leaf.is_a?(Sport)
      link_to leaf.desc, :controller => 'summary', :action => 'show', :id => leaf.id
    else
      link_to leaf.desc, :controller => 'period', :action => 'show', :id => leaf.id
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
