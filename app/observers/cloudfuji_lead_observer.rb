# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

class CloudfujiLeadObserver < ActiveRecord::Observer
  observe :lead

  def after_update(lead)
    # Find all event rules where the lead attribute is one of the changed fields
    EventRule.find_all_by_event_category_and_lead_attribute('lead_attribute_changed', lead.changes.keys).each do |rule|
      old, new = lead.changes[rule.lead_attribute]
      rule.process(lead, {'old_value' => old, 'new_value' => new})  # Send [old, new] values as matching data
    end
  end
end
