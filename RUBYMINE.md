# RUBYMINE SETUP FOR MONOREPO

This is the clean state example in case RM ruins it.

Root project's `.idea/modules.xml` (these files' contents change rarely)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectModuleManager">
    <modules>
      <module fileurl="file://$PROJECT_DIR$/.idea/qd3v.iml" filepath="$PROJECT_DIR$/.idea/qd3v.iml" />
      <module fileurl="file://$PROJECT_DIR$/qd3v-core/.idea/qd3v-core.iml" filepath="$PROJECT_DIR$/qd3v-core/.idea/qd3v-core.iml" />
      <module fileurl="file://$PROJECT_DIR$/qd3v-openai/.idea/qd3v-openai.iml" filepath="$PROJECT_DIR$/qd3v-openai/.idea/qd3v-openai.iml" />
      <module fileurl="file://$PROJECT_DIR$/qd3v-pg/.idea/qd3v-pg.iml" filepath="$PROJECT_DIR$/qd3v-pg/.idea/qd3v-pg.iml" />
      <module fileurl="file://$PROJECT_DIR$/qd3v-testing-core/.idea/qd3v-testing-core.iml" filepath="$PROJECT_DIR$/qd3v-testing-core/.idea/qd3v-testing-core.iml" />
    </modules>
  </component>
</project>
```

Any `*.iml` file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<module type="RUBY_MODULE" version="4">
  <component name="ModuleRunConfigurationManager">
    <shared />
  </component>
  <component name="NewModuleRootManager">
    <content url="file://$MODULE_DIR$">
      <sourceFolder url="file://$MODULE_DIR$/features" isTestSource="true" />
      <sourceFolder url="file://$MODULE_DIR$/spec" isTestSource="true" />
      <sourceFolder url="file://$MODULE_DIR$/test" isTestSource="true" />
    </content>
    <orderEntry type="jdk" jdkName="ruby-3.4.0-p-2" jdkType="RUBY_SDK" />
    <orderEntry type="sourceFolder" forTests="false" />
  </component>
</module>
```

Each subproject's `modules.xml` example (should be generated correctly)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectModuleManager">
    <modules>
      <module fileurl="file://$PROJECT_DIR$/.idea/qd3v-openai.iml" filepath="$PROJECT_DIR$/.idea/qd3v-openai.iml" />
    </modules>
  </component>
</project>
```

Attempt to git-track these files lead to expected mess: `*.iml` contents constantly changes
depending on how the subproject is opened: as part of monorepo, or in solo mode, which adds
`<orderEntry type="module-library">` section, the former does the opposite.
