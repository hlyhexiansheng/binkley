<#--
TODO: FreeMarker template fixes
    * Whitespace
    * Condense with macros
    * Recurive methods types
    * Get rid of "type" for builtin types
-->
<#macro jvalue type value="\n"><@compress>
    <#if value?is_string>
        <#if "\n" == value>null<#else>"${value}"</#if>
    <#elseif value?is_boolean || value?is_number>${value?c}<#if "double" == type>d</#if>
    <#else>${type}.valueOf("${value}")</#if>
</@compress></#macro>
<#if package?has_content>
package ${package};

</#if>
<#if doc??>
/** ${doc} */
</#if>
@javax.annotation.Generated(
    value="${generator}",
    date="${now}",
    comments="${comments}")
@hm.binkley.annotation.YamlGenerate.Definition(${definition})
<#if type == "Enum">public enum ${name} {
<#list values?keys as value>
    <#if values[value].doc??>
    /** ${values[value].doc} */
    <#else>
    /**
    * @{code ${value}} is undocumented.
    *
    * @todo Documentation
    */
    </#if>
    @hm.binkley.annotation.YamlGenerate.Definition(${values[value].definition})
    ${value}<#if value_has_next>,<#else>;</#if>
</#list>
}<#else>public class ${name}<#if parent??> extends ${parent}</#if> {
<#list methods?keys as key>
<#assign has_init = false/>
<#if methods[key].value??>
    <#if methods[key].value?is_sequence>
    <#assign has_init = true/>
    private final java.util.List<Object> ${key} = new java.util.ArrayList<>(${methods[key].value?size});
    <#if methods[key].value?has_content>
    {
        <#list methods[key].value as each>
        ${key}.add(<@jvalue type=methods[key].type value=each/>);
        </#list>
    }
    </#if>
<#elseif methods[key].value?is_hash>
    <#assign has_init = true/>
    private final java.util.Map<String, Object> ${key} = new java.util.HashMap<>(${methods[key].value?size});
    <#if methods[key].value?has_content>
    {
        <#list methods[key].value?keys as each>
        ${key}.put("${each}", <@jvalue type=methods[key].type value=methods[key].value[each]/>);
        </#list>
    }
</#if>
</#if>
</#if>
</#list>
<#list methods?keys as key>
    <#if has_init || 0 != key_index>

    </#if>
    <#if methods[key].doc??>
    /** ${methods[key].doc} */
    @hm.binkley.annotation.YamlGenerate.Documentation("${methods[key].doc}")
    </#if>
    <#if methods[key].override>
    @Override
    </#if>
    @hm.binkley.annotation.YamlGenerate.Definition(${methods[key].definition})
    public <#if "text" == methods[key].type>String<#elseif "list" == methods[key].type>java.util.List<Object><#elseif "map" == methods[key].type>java.util.Map<String, Object><#else>${methods[key].type}</#if> ${key}() {
        return <#if methods[key].value?? && (methods[key].value?is_sequence || methods[key].value?is_hash)>${key}<#else><@jvalue type=methods[key].type value=methods[key].value/></#if>;
    }
</#list>
}</#if>