# (2013) Modified by Benjamin Ninassi for rails 3.2 compatibility
# ROR SubList Plugin
# Luke Galea - galeal@ideaforge.org
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

The Ruby on Rails SubList Plugin makes it easy to have dynamic lists of related
models on a single editing page. 

The plugin is designed for models with one or more has_many relationship with
other models. By using AJAX for adding and removing &quot;sub-forms&quot; one
can present the user with a single edit page that creates/edits the parent model
as well as all of the children.

Usage:

Place the sub_list directory in the vendor/plugins dir of your application.

In the controller which you wish to have a sub list displayed, add the following lines:
  include UIEnhancements::SubList
  helper :SubList  
  
  sub_list 'SubModel', 'parent' do |new_research_student|
   #Place any construction (ie. defaults) required here
  end

Replace 'SubModel' with the class name of the sub model you wish to make available.
Replace 'parent' with the parent object. 

For instance, if you wish to have a Person controller that has a sub list of Dogs for each 
person, the sub model would be 'Dog' and the parent would be 'person'. It is expected that 
@person would exist and that it contains a has_many relationship named 'dogs'.

The create and edit methods of the controller must be modified as below:
  def create
    @person = Person.new(@params[:person])
      
    success = true
    success &&= initialize_dogs
    success &&= @person.save
  
    if success
      flash[:notice] = 'Person was successfully created.'
      redirect_to :action => 'list'
    else
      prepare_dogs
      render_action 'new'
    end   
  end

Make similar changes to edit. These changes call metaprogramming methods added by the sub_list call above. The methods create or update any sub list items and validate them. In case of failure, the prepare_xxxx method ensures that the validation failures are properly displayed and sets up for redisplay of the page.

In the _form.rhtml to display the sub list (add, remove, etc):
 <fieldset>
	<legend>
		Investigators
	</legend>

	<% unless controller.action_name == 'show' %>
		<%= sub_list_add_link 'Dog', 'Add Dog' %>
	<% end %>

	<%= sub_list_content 'Dog', 'person' %>
 </fieldset>

 And to define the sub form used for editing the sub list items, create a partial for the sub model and place it in the view directory of the parent.
 For instance, _dog.rhtml:
	<% @dog = dog %>
	<div id="<%= "dog_#{dog.id}" %>">
		<fieldset>			
			<label class="first" for="dog[]_firstname">
				First Name
				<%= text_field 'dog[]', 'firstname' %>
			</label>
			
			<label for="dog[]_firstname">
				Last Name
				<%= text_field 'dog[]', 'lastname' %>
			</label>
			
			<% unless controller.action_name == 'show' %>
   		 		<%= sub_list_remove_link dog, 'Dog' %>
  			<% end %>			
		</fieldset>
	</div>

For an example of how this looks see the screen movie sub_list.swf included.
