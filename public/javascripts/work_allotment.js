function msgFor(num){
    if(num<0)
        return "<span class='deficit'>"+(0-num)+" deficit</span>";
    if(num==0)
        return "<span class='ok'>OK</span>";
    if(num>0)
        return "<span class='remaining'>"+num+" remaining</span>";
}
function checkEmployeeAssignedHours(all_opts,emp_id){
    max_limit = employee_limits[emp_id];
    assgnd = all_opts.findAll(function (inp){
        return inp.value == emp_id;
    });
    assigned_hrs = 0;
    assgnd.each(function(el){
        assigned_hrs += subject_limits[el.id.split('_').last()];
    });
    $('emp_status_'+emp_id).update(msgFor(max_limit-assigned_hrs));
    
    return (assigned_hrs<=max_limit);
}

function recalculateAll(){
    all_opts = $$('.category-employee-options select');
    valid = true;
    for(i in employee_limits){
        valid = checkEmployeeAssignedHours(all_opts,i) && valid;
    }
    return valid;
}
document.observe("dom:loaded", function() {
    $$('.category-employee-options select').invoke('observe','change',recalculateAll);
    //$('work_allotment_form').onsubmit=recalculateAll;
    recalculateAll();//init
});