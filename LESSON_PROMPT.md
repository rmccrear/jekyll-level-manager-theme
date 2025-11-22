# Prompt for Creating Lessons and Levels

Use this prompt template to create lessons and levels in the style of the Jekyll Level Manager Theme project guides.

## Format for a Complete Lesson

A complete lesson should follow this structure:

```markdown
# [Lesson Title]

[Introduction paragraph - welcome and context]

**What you'll learn:**
- [Learning objective 1]
- [Learning objective 2]
- [Learning objective 3]

**How this works:**
- [Explanation of the lesson structure]
- [How levels build on each other]
- [What students can expect]

**Each level includes:**
- **User Story**: What you're building and why it matters
- **Instructions**: Step-by-step guidance to complete the task
- **Code Hints**: Examples and snippets to help you along (use only if you need it.)
- **Diving Deeper**: Extra explanations and videos for curious minds
- **Check**: Verification steps to make sure everything works

---

{% level subtitle="[Level Name]" %}
# Level {{ level.number }}: [Level Title]

**Goal:** [Clear, concise goal statement]

**User Story:** As a [persona/role], I want to [action] so that [benefit/outcome].

---

## What You'll Do

[Brief paragraph describing what the student will accomplish in this level]

## Instructions

[Step-by-step instructions in bullet points or numbered list]
- [Specific action step 1]
- [Specific action step 2]
- [Specific action step 3]

## 💡 Code Hints

Need help with [topic]? Check out these snippets:

{% showme "Show Me: [Title]" %}
```language
[Code example or snippet]
```
{% endshowme %}

[Repeat showme blocks as needed]

## 🔍 Diving Deeper

[Optional section with additional explanations, context, or resources]

**Why [concept]?**
- [Explanation 1]
- [Explanation 2]

**How [process] works:**
- [Step-by-step explanation]

**Resources:**
- [Links to additional documentation, videos, etc.]

## ✅ Check

1. [Verification item 1]
2. [Verification item 2]
3. [Verification item 3]
4. [Verification item 4]
5. [Verification item 5]

---

{% endlevel %}
```

## Key Style Guidelines

### Level Markers
- Start each level with `{% level subtitle="[Level Name]" %}`
- End each level with `{% endlevel %}`
- Use level variables: `{{ level.number }}`, `{{ level.subtitle }}`

### Headers and Sections
- Main lesson title: `# [Title]`
- Level title: `# Level {{ level.number }}: [Title]`
- Use `##` for major sections (What You'll Do, Instructions, etc.)
- Use `---` (three dashes) as section separators

### Content Tone
- **Clear and encouraging**: Use second person ("you", "your")
- **Step-by-step**: Break complex tasks into small, manageable steps
- **Specific**: Give concrete examples and actionable instructions
- **Supportive**: Remind students they can use hints if needed

### User Stories
Follow this format:
```
**User Story:** As a [specific persona], I want to [specific action] so that [specific benefit/outcome].
```

Examples:
- "As a developer, I want to connect my React app to a database so that I can store data permanently."
- "As a student, I want to understand form handling so that I can build interactive user interfaces."

### Goals
- Start with: **Goal:** 
- Be specific and measurable
- One sentence maximum

### Instructions Section
- Use bullet points for most instructions
- Number steps when order is critical
- Include specific commands, file names, or code snippets inline when helpful
- Link to external resources when appropriate

### Code Hints Section
- Always start with: "Need help with [topic]? Check out these snippets:"
- Use `{% showme %}` tags to create collapsible sections
- Format: `{% showme "Show Me: [Descriptive Title]" %}`
- Include code blocks with language specification
- Can include multiple showme blocks per level
- Can include screenshots or diagrams in showme blocks

### Diving Deeper Section
- Optional but recommended for important concepts
- Use bold subheadings for different topics
- Include explanations, context, and resources
- Help curious students understand the "why" behind the "what"

### Check Section
- Always numbered list (1., 2., 3., etc.)
- Each item should be a verifiable action or state
- 3-7 items is typical
- Start with verbs when possible (e.g., "You have...", "You can...", "The form...")

## Example Level Structure

```markdown
{% level subtitle="Database Setup" %}
# Level {{ level.number }}: Database Setup

**Goal:** Configure your Supabase database with tables and security policies.

**User Story:** As a developer, I want to set up my database tables and security policies so that I can store and retrieve potluck data securely.

---

## What You'll Do

Follow the Supabase setup guides to create your database tables and configure access policies.

## Instructions

- Complete the [Supabase Setup Guide](link) to create your account and project
- Create a `potluck_meals` table with these columns:
  - `meal_name` (text)
  - `guest_name` (text)
  - `serves` (integer)
  - `kind_of_dish` (text)
- Add at least 3 sample meals
- Set up read policies and insert policies for public access
- Follow the Supabase React Setup Guide to configure environment variables

## 💡 Code Hints

Need help with table creation? Check out these snippets:

{% showme "Show Me: Creating the table" %}
```sql
CREATE TABLE potluck_meals (
  id BIGSERIAL PRIMARY KEY,
  meal_name TEXT NOT NULL,
  guest_name TEXT,
  serves INTEGER,
  kind_of_dish TEXT
);
```
{% endshowme %}

## 🔍 Diving Deeper

**Why do we need security policies?**

Row Level Security (RLS) policies control who can read and write data in your tables. Without them, your database would be either completely open (insecure) or completely locked (unusable).

**How RLS works:**
- Policies are SQL rules that check conditions before allowing operations
- You can create policies that allow public read access but restrict writes
- Policies are evaluated for each row, giving fine-grained control

## ✅ Check

1. You have created a Supabase account and project
2. The `potluck_meals` table exists with the correct columns
3. You have added at least 3 sample meals to the table
4. Read policies are configured and allow public access
5. Insert policies are configured and allow public access
6. Environment variables are set in your `.env.local` file

---

{% endlevel %}
```

## Special Level Types

### Challenge Level
```markdown
{% level subtitle="Bonus Challenges" %}
# Level {{ level.number }}: Bonus Challenges ⚡

**CHALLENGE LEVEL**

**User Story:** As a developer, I want to implement advanced features so that I can create a more impressive and functional app.

---

## What You'll Do

Choose from these advanced challenges to extend your potluck app.

## Challenge Options

Complete at least 2 of the following challenges:

### Challenge 1: [Title]
[Description of challenge]

### Challenge 2: [Title]
[Description of challenge]

## ✅ Check

1. You have chosen at least 2 challenges
2. [Challenge-specific check items]
3. Your new features work correctly
4. You have tested thoroughly

---

{% endlevel %}
```

### Planning Level
```markdown
{% level subtitle="Planning" %}
# Level {{ level.number }}: Planning

**Goal:** Plan your [project/app] using the [activity guide/planning template].

**User Story:** As a developer, I want to plan my [database/component/feature] structure so that I can build my [app] efficiently.

---

### 📋 Before You Start

**Complete the [Activity Guide] first!** Work through Steps 1-4 of the Activity Guide to:
- Plan your [database tables/component structure]
- Design your [features/architecture]
- Map out your app's [workflow/features]
- Set success criteria

This planning will help you build your app more efficiently!

---

## What You'll Do

Take time to plan your [project] using the structured [activity guide/planning template].

### Instructions

- **Understand the Requirements**: Review what you need to build
- **Plan Your [Component]**: [Specific planning step]
- **Plan Your [Other Component]**: [Another planning step]
- **Set Success Criteria**: Know what "done" looks like

**Key Planning Questions:**
- [Question 1]
- [Question 2]
- [Question 3]

**Time Investment**: Spend 15-20 minutes on planning - it will save you hours of debugging later!

## ✅ Check

1. You have reviewed the [activity guide/planning template]
2. You understand the project requirements
3. You have planned your [component/feature] structure
4. You have designed your [architecture/features]
5. You have set clear success criteria

---

{% endlevel %}
```

### Final/Completion Level
```markdown
{% level subtitle="Project Complete!" %}
# Level {{ level.number }}: Project Complete! 🎉

**Congratulations!** You've successfully built a complete [project description]!

## What You've Accomplished

You've built a fully functional app that demonstrates:

- ✅ **[Skill/Category]** - [Achievement description]
- ✅ **[Skill/Category]** - [Achievement description]
- ✅ **[Skill/Category]** - [Achievement description]

## Skills You've Developed

Through this project, you've gained hands-on experience with:

- [Skill or tool 1]
- [Skill or tool 2]
- [Skill or tool 3]

## Next Steps

After completing this project, consider exploring:

- [Advanced topic 1]
- [Advanced topic 2]
- [Advanced topic 3]

## Resources

- [Official Documentation](link)
- [Additional Resources](link)
- [Learning Materials](link)

## 🎊 Well Done!

You've completed a significant milestone in your [learning journey]. Keep building, keep learning, and keep growing!

**Project Status: Complete!** ✨

---

{% endlevel %}
```

## Tips for Writing Effective Levels

1. **Progressive Complexity**: Start simple and gradually increase difficulty
2. **Clear Objectives**: Each level should have one clear, achievable goal
3. **Relevant User Stories**: Connect technical tasks to real-world scenarios
4. **Actionable Instructions**: Use imperative verbs and specific steps
5. **Support Without Handholding**: Provide hints but encourage problem-solving
6. **Verification Steps**: Make checks specific enough to confirm understanding
7. **Encouraging Tone**: Celebrate progress and acknowledge challenges

## Prompt Template for AI Assistance

When asking an AI to create a lesson or level, use this template:

```
Create a [lesson/level] about [topic] following this style guide:

[Paste the relevant format from above]

Requirements:
- Topic: [specific topic]
- Target audience: [beginner/intermediate/advanced]
- Number of levels: [if creating a full lesson]
- Key learning objectives: [list objectives]
- Prerequisites: [what students should know first]

Please create [a lesson with X levels / a single level] that teaches [topic] 
in a clear, step-by-step manner with code hints, verification steps, and 
optional deeper explanations.
```

