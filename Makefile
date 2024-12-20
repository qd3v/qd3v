# List of projects
PROJECTS := qd3v-core \
	qd3v-openai \
	qd3v-testing-core \
	qd3v-pg

# Command templates
# Removed, too noisy: --regenerate-todo
# There's --fail-level fatal
cmd_cop_fix = (cd $(1) && bundle exec rubocop --autocorrect || true)
cop:
	bin/cop

cmd_bun = (cd $(1) && bundle install)
all/bun:
	$(foreach project,$(PROJECTS),$(call cmd_bun,$(project));)

cmd_bunu = (cd $(1) && bundle update)
all/bunu:
	$(foreach project,$(PROJECTS),$(call cmd_bunu,$(project));)
