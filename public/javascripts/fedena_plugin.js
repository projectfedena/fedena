function render_generic_hook(hooks){

    var link_box, link_head, link_desc, link, target;
    hooks.each(function(hook){
        link_box = new Element('div',{
            'class':'link-box'
        });
        link_head = new Element('div',{
            'class':'link-heading'
        });
        link_desc = new Element('div',{
            'class':'link-descr'
        });
        link = new Element('a',{
            'href':'/'+hook['destination']['controller']+'/'+hook['destination']['action']
        });
        target = $(hook["target_id"])? $(hook["target_id"]) : $$('.box').first();
        link.update(hook['title']);
        link_desc.update(hook['description']);
        link_head.update(link);
        link_box.update(link_head);
        link_box.appendChild(link_desc);
        target.appendChild(link_box);
        
    });

}
