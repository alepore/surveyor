Feature: Survey creation
  As a survey participant
  I want to take a survey
  So that I can get paid

  Scenario: Basic questions
    Given the survey
    """
      survey "Favorites" do
        section "Colors" do
          label "You with the sad eyes don't be discouraged"

          question_1 "What is your favorite color?", :pick => :one
          answer "red"
          answer "blue"
          answer "green"
          answer :other

          q_2b "Choose the colors you don't like", :pick => :any
          a_1 "orange"
          a_2 "purple"
          a_3 "brown"
          a :omit
        end
      end
    """
    When I start the "Favorites" survey
    Then I should see "You with the sad eyes don't be discouraged"
    And I choose "red"
    And I choose "blue"
    And I check "orange"
    And I check "brown"
    And I press "Click here to finish"
    Then there should be 1 response set with 3 responses with:
      | answer |
      | blue   |
      | orange |
      | brown  |
      
  Scenario: Default answers
    Given the survey
    """
      survey "Favorites" do
        section "Foods" do
          question_1 "What is your favorite food?"
          answer "food", :string, :default_value => "beef"
        end
        section "Section 2" do
        end
        section "Section 3" do
        end
      end
    """
    When I start the "Favorites" survey
    And I press "Section 3"
    And I press "Click here to finish"
    Then there should be 1 response set with 1 responses with:
      | string_value |
      | beef |
    Then the survey should be complete

    When I start the "Favorites" survey
    And I fill in "food" with "chicken"
    And I press "Foods"
    And I press "Section 3"
    And I press "Click here to finish"
    Then there should be 2 response set with 2 responses with:
      | string_value    |
      | chicken |

  Scenario: Quiz time
    Given the survey
    """
      survey "Favorites" do
        section "Foods" do
          question_1 "What is the best meat?", :pick => :one, :correct => "oink"
          a_oink "bacon"
          a_tweet "chicken"
          a_moo "beef"
        end
      end
    """
    Then question "1" should have correct answer "oink"
    
  Scenario: Custom css class
    Given the survey
    """
      survey "Movies" do
        section "First" do
          q "What is your favorite movie?"
          a :string, :custom_class => "my_custom_class"
          q "What is your favorite state?"
          a :string
        end
      end
    """
    When I start the "Movies" survey
    Then the element "input[type='text']:first" should have the class "my_custom_class"
    # Then the element "input[type='text']:last" should not contain the class attribute
    
  Scenario: A pick one question with an option for other
    Given the survey
    """
      survey "Favorites" do
        section "Foods" do
          q "What is the best meat?", :pick => :one
          a "bacon"
          a "chicken"
          a "beef"
          a "other", :string
        end
      end
    """
    When I start the "Favorites" survey
    Then I choose "bacon"
    And I press "Click here to finish"
    Then there should be 1 response set with 1 response with:
    | bacon |

  Scenario: Repeater with a dropdown
    Given the survey
    """
      survey "Movies" do
        section "Preferences" do
          repeater "What are you favorite genres?" do
            q "Make", :pick => :one, :display_type => :dropdown
            a "Action"
            a "Comedy"
            a "Mystery"
          end
        end
      end
    """
    When I start the "Movies" survey
    Then a dropdown should exist with the options "Action, Comedy, Mystery"
    
  Scenario: A pick one question with an option for other
    Given the survey
    """
      survey "Favorites" do
        section "Foods" do
          q "What is the best meat?", :pick => :one
          a "bacon"
          a "chicken"
          a "beef"
          a "other", :string
        end
      end
    """
    When I start the "Favorites" survey
    Then I choose "other"
    And I fill in "/.*string_value.*/" with "shrimp"
    And I press "Click here to finish"
    Then there should be 1 response set with 1 response with:
    | shrimp |

  Scenario: Checkboxes with text area
    Given the survey
    """
      survey "Websites" do
        section "Search engines" do
          q "Have you ever used the following services?", :pick => :any
          a "Yellowpages.com|Describe your experience", :text
          a "Google.com|Describe your experience", :text
          a "Bing.com|Describe your experience", :text
        end
      end
    """
    When I start the "Websites" survey
    Then there should be 3 checkboxes
    And there should be 3 text areas

  Scenario: "Double letter rule keys"
    Given the survey
    """
      survey "Doubles" do
        section "Two" do
          q_twin "Are you a twin?", :pick => :one
          a_yes "Oh yes"
          a_no "Oh no"

          q_two_first_names "Do you have two first names?", :pick => :one
          a_yes "Why yes"
          a_no "Why no"

          q "Do you want to be part of an SNL skit?", :pick => :one
          a_yes "Um yes"
          a_no "Um no"
          dependency :rule => "A or AA"
          condition_A :q_twin, "==", :a_yes
          condition_AA :q_two_first_names, "==", :a_yes
        end
        section "Deux" do
          label "Here for the ride"
        end
        section "Three" do
          label "Here for the ride"
        end
      end
    """
    When I start the "Doubles" survey
    Then I choose "Oh yes"
    And I press "Deux"
    And I press "Two"
    Then the question "Do you want to be part of an SNL skit?" should be triggered

  Scenario: "Changing dropdowns"
    Given the survey
    """
      survey "Drop" do
        section "Like it is hot" do
          q "Name", :pick => :one, :display_type => :dropdown
          a "Snoop"
          a "Dogg"
          a "D-O double G"
          a "S-N double O-P, D-O double G"
        end
        section "Two" do
          label "Here for the ride"
        end
        section "Three" do
          label "Here for the ride"
        end
      end
    """
    When I start the "Drop" survey
    Then I select "Snoop" from "Name"
    And I press "Two"
    And I press "Like it is hot"
    And I select "Dogg" from "Name"
    And I press "Two"
    Then there should be 1 response with answer "Dogg"
