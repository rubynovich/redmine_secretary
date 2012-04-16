module OutgoingLettersHelper
  def outgoing_letter_heading(object)  
    [t(:field_outgoing_code), object.outgoing_code, t(:dated), format_date(object.created_on)].join(' ')
  end
end
