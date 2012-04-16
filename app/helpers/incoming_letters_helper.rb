module IncomingLettersHelper
  def incoming_letter_heading(object)  
    [t(:field_incoming_code), object.incoming_code, t(:dated), format_date(object.created_on)].join(' ')
  end
end
