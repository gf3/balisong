Feature: Pages
  In order to browse the site's content
  as a visitor
  I can load each page of content


  Scenario: Basic page without date in the id
    Given the following pages:
      | title   | body                      | id                | categories          |
      | Whiskey | A page with no date       | whiskey           | alcohol, bourbon, scotch, whiskey |
    When I go to the path "/whiskey"
    Then I should see "A page with no date"
    And The page title should include "Whiskey"
    And I should see the following list of links with css id "categories":
      | alcohol  | /category/alcohol  |
      | bourbon  | /category/bourbon  |
      | scotch   | /category/scotch   |
      | whiskey  | /category/whiskey  |


  Scenario: Basic page with date in the id
    Given the following pages:
      | title   | body                      | id                  | categories                        |
      | Whiskey | A page with no date       | 2010-02-01-whiskey  | alcohol, bourbon, scotch, whiskey |
    When I go to the path "/2010/02/01/whiskey"
    Then I should see "A page with no date"
    And The page title should include "Whiskey"
    And I should see the following list of links with css id "categories":
      | alcohol | /category/alcohol |
      | bourbon | /category/bourbon |
      | scotch  | /category/scotch  |
      | whiskey | /category/whiskey |


  @wip
  Scenario: Missing page
    Given the following pages:
      | title   | body      | id       |
      | Bourbon | A page.   | bourbon  |
    When I go to the path "/scotch"
    Then the response should be "not found"


  Scenario: Page with multiple parts
    Given the following pages:
      | title   | id         |
      | Bourbon | bourbon    |
    And the page with id "bourbon" has part "main.md" with content:
      """
      This is a post about *bourbon*.
      It includes a mardown part:
      {{part1.md | markdown}}
      And another markdown part with no explicit formatter:
      {{part2.md}}
      """
    And the page with id "bourbon" has part "part1.md" with content "This is part 1."
    And the page with id "bourbon" has part "part2.md" with content "This is part 2."
    When I go to the path "/bourbon"
    Then I should see "This is part 1"
    And I should see "This is part 2"
    

  Scenario: Page with HTML rendered as source code
    Given the following pages:
      | title     | id         |
      | HTML Test | htmltest   |
    And the page with id "htmltest" has part "main.md" with content:
      """
      Some HTML rendered:
      {{knobcreek.html | html}}
      And the same HTML as code source:
      {{knobcreek.html | code(html)}}
      """
    And the page with id "htmltest" has part "knobcreek.html" with content "<h2>So delicious</h2>"
    When I go to the path "/htmltest"
    And I should see "So delicious" within "h2"
    And I should see "<h2>So delicious</h2>" within "pre"

    
  Scenario: Page with ruby rendered as source code
    Given the following pages:
      | title     | id         |
      | Ruby Test | rubytest   |
    And the page with id "rubytest" has part "main.md" with content:
      """
      Here is some sample Ruby code:
      {{sample.rb | code(ruby)}}
      """
    And the page with id "rubytest" has part "sample.rb" with content:
      """
      def wtf(x)
        if x < 17 && x > 5
          puts "yay, the < and > were escaped properly"
        end
      end
      """
    When I go to the path "/rubytest"
    Then I should see "def wtf" within "pre"
    Then I should see "yay, the < and > were escaped properly" within "pre"
    

    Scenario: Page with text file part
    Given the following pages:
      | title     | id         |
      | Text Test | texttest   |
    And the page with id "texttest" has part "main.md" with content:
      """
      Here is some plain text:
      {{something.txt | text}}

      """
    And the page with id "texttest" has part "something.txt" with content "This is a text file."
    When I go to the path "/texttest"
    Then I should see "This is a text file" within "pre"


    Scenario: Page with image
    Given the following pages:
      | title               | id         |
      | Page with image     | image1     |
    And the page with id "image1" has part "main.md" with content:
      """
      A picture of a cat:
      {{cat.jpg | image}}
      """
    And the page with id "image1" has part "cat.jpg" with content from file "cat.jpg"
    When I go to the path "/image1"
    Then I should see the image "/image1/cat.jpg"

    When I go to the path "/image1/cat.jpg"
    Then the response should match the content of the file "cat.jpg"
    And the browser should be told to display the response as a JPEG image

    When I go to the path "/image1/cat.jpg?download=true"
    Then the response should match the content of the file "cat.jpg"
    And the browser should be told to save the response as a file


    Scenario: Page with file to download
    Given the following pages:
      | title               | id         |
      | Page with zip file  | download1  |
    And the page with id "download1" has part "main.md" with content:
      """
      A file to download:
      {{cat.zip | download}}
      """
    And the page with id "download1" has part "cat.zip" with content from file "cat.zip"
    When I go to the path "/download1"
    Then I should see a link to "/download1/cat.zip?download=true" with text "cat.zip"

    When I go to the path "/download1/cat.zip?download=true"
    Then the response should match the content of the file "cat.zip"
    And the browser should be told to save the response as a file


