using System;
using System.Collections.Generic;

namespace SchemaComposer {
    namespace Keywords {
        public enum Known : ushort {
            // core keywords
            Anchor        = 01,
            Comment       = 02,
            Defs          = 03,
            DynamicAnchor = 04,
            DynamicRef    = 05,
            Id            = 06,
            Ref           = 07,
            Schema        = 08,
            Vocabulary    = 09,
            // applicator keywords
            AdditionalProperties  = 10,
            AllOf                 = 11,
            AnyOf                 = 12,
            Contains              = 13,
            DependentSchemas      = 14,
            Else                  = 15,
            If                    = 16,
            Items                 = 17,
            Not                   = 18,
            OneOf                 = 19,
            PatternProperties     = 20,
            PrefixItems           = 21,
            Properties            = 22,
            PropertyNames         = 23,
            Then                  = 24,
            UnevaluatedItems      = 25,
            UnevaluatedProperties = 26,
            // content keywords
            ContentEncoding  = 27,
            ContentMediaType = 28,
            ContentSchema    = 29,
            // format  keywords
            Format = 30,
            // metadata keywords
            Default     = 31,
            Deprecated  = 32,
            Description = 33,
            Examples    = 34,
            ReadOnly    = 35,
            Title       = 36,
            WriteOnly   = 37,
            // validation keywords
            Const             = 38,
            DependentRequired = 39,
            Enum              = 40,
            ExclusiveMaximum  = 41,
            ExclusiveMinimum  = 42,
            MaxContains       = 43,
            Maximum           = 44,
            MaxItems          = 45,
            MaxLength         = 46,
            MaxProperties     = 47,
            MinContains       = 48,
            Minimum           = 49,
            MinItems          = 50,
            MinLength         = 51,
            MinProperties     = 52,
            MultipleOf        = 53,
            Pattern           = 54,
            Required          = 55,
            Type              = 56,
            UniqueItems       = 57,
            // vscode keywords
            DefaultSnippets          = 101,
            ErrorMessage             = 102,
            PatternErrorMessage      = 103,
            DeprecationMessage       = 104,
            EnumDescriptions         = 105,
            MarkdownEnumDescriptions = 106,
            MarkdownDescription      = 107,
            DoNotSuggest             = 108,
            SuggestSortText          = 109,
            AllowComments            = 110,
            AllowTrailingCommas      = 111
        }

        public enum Compatible : ushort {
            // core keywords
            Anchor        = 01,
            Comment       = 02,
            Defs          = 03,
            DynamicAnchor = 04,
            DynamicRef    = 05,
            Id            = 06,
            Ref           = 07,
            Schema        = 08,
            Vocabulary    = 09,
            // applicator keywords
            AdditionalProperties  = 10,
            AllOf                 = 11,
            AnyOf                 = 12,
            Contains              = 13,
            DependentSchemas      = 14,
            Else                  = 15,
            If                    = 16,
            Items                 = 17,
            Not                   = 18,
            OneOf                 = 19,
            PatternProperties     = 20,
            PrefixItems           = 21,
            Properties            = 22,
            PropertyNames         = 23,
            Then                  = 24,
            UnevaluatedItems      = 25,
            UnevaluatedProperties = 26,
            // content keywords
            ContentEncoding  = 27,
            ContentMediaType = 28,
            ContentSchema    = 29,
            // format  keywords
            Format = 30,
            // metadata keywords
            Default     = 31,
            Deprecated  = 32,
            Description = 33,
            Examples    = 34,
            ReadOnly    = 35,
            Title       = 36,
            WriteOnly   = 37,
            // validation keywords
            Const             = 38,
            DependentRequired = 39,
            Enum              = 40,
            ExclusiveMaximum  = 41,
            ExclusiveMinimum  = 42,
            MaxContains       = 43,
            Maximum           = 44,
            MaxItems          = 45,
            MaxLength         = 46,
            MaxProperties     = 47,
            MinContains       = 48,
            Minimum           = 49,
            MinItems          = 50,
            MinLength         = 51,
            MinProperties     = 52,
            MultipleOf        = 53,
            Pattern           = 54,
            Required          = 55,
            Type              = 56,
            UniqueItems       = 57
        }

        public enum Core : ushort {
            Anchor        = 01,
            Comment       = 02,
            Defs          = 03,
            DynamicAnchor = 04,
            DynamicRef    = 05,
            Id            = 06,
            Ref           = 07,
            Schema        = 08,
            Vocabulary    = 09
        }
        public enum Applicator : ushort {
            AdditionalProperties  = 10,
            AllOf                 = 11,
            AnyOf                 = 12,
            Contains              = 13,
            DependentSchemas      = 14,
            Else                  = 15,
            If                    = 16,
            Items                 = 17,
            Not                   = 18,
            OneOf                 = 19,
            PatternProperties     = 20,
            PrefixItems           = 21,
            Properties            = 22,
            PropertyNames         = 23,
            Then                  = 24,
            UnevaluatedItems      = 25,
            UnevaluatedProperties = 26
        }

        public enum Content : ushort {
            ContentEncoding  = 27,
            ContentMediaType = 28,
            ContentSchema    = 29
        }

        public enum Format : ushort {
            Format = 30
        }

        public enum Metadata : ushort {
            Default     = 31,
            Deprecated  = 32,
            Description = 33,
            Examples    = 34,
            ReadOnly    = 35,
            Title       = 36,
            WriteOnly   = 37
        }

        public enum Validation : ushort {
            Const             = 38,
            DependentRequired = 39,
            Enum              = 40,
            ExclusiveMaximum  = 41,
            ExclusiveMinimum  = 42,
            MaxContains       = 43,
            Maximum           = 44,
            MaxItems          = 45,
            MaxLength         = 46,
            MaxProperties     = 47,
            MinContains       = 48,
            Minimum           = 49,
            MinItems          = 50,
            MinLength         = 51,
            MinProperties     = 52,
            MultipleOf        = 53,
            Pattern           = 54,
            Required          = 55,
            Type              = 56,
            UniqueItems       = 57
        }

        public enum VSCode : ushort {
            DefaultSnippets          = 101,
            ErrorMessage             = 102,
            PatternErrorMessage      = 103,
            DeprecationMessage       = 104,
            EnumDescriptions         = 105,
            MarkdownEnumDescriptions = 106,
            MarkdownDescription      = 107,
            DoNotSuggest             = 108,
            SuggestSortText          = 109,
            AllowComments            = 110,
            AllowTrailingCommas      = 111
        }
    }

    public class Keyword {
        public static Dictionary<string, SchemaComposer.Keyword> Registry {get; internal set;}

        public string Name {get; private set;}
        public Nullable<ushort> Value {get; private set;}
        public Type JsonSchemaDotNetKeywordType {get; private set;}

        public bool IsCompatible {
            get {
                return Enum.IsDefined(
                    (typeof(SchemaComposer.Keywords.Compatible)),
                    this.Value
                );
            }
        }

        public bool IsCompatibleCore {
            get {
                return Enum.IsDefined(
                    (typeof(SchemaComposer.Keywords.Core)),
                    this.Value
                );
            }
        }

        public bool IsVSCode {
            get {
                return Enum.IsDefined(
                    (typeof(SchemaComposer.Keywords.VSCode)),
                    this.Value
                );
            }
        }

        public bool IsCustom {
            get {
                return this.Value == 0;
            }
        }

        public override string ToString() {
            return this.Name;
        }

        public Keyword(SchemaComposer.Keywords.Known keyword) {
            this.Value = (ushort)keyword;
            this.Name  = keyword.ToString();
            this.Name = char.ToLower(this.Name[0]) + this.Name[1..];
            if (this.IsCompatibleCore) {
                this.Name = $"${this.Name}";
            }
            if (this.IsCompatible) {
                this.JsonSchemaDotNetKeywordType = Type.GetType(
                    $"Json.Schema.{keyword}Keyword"
                );
            }
        }
        public Keyword(string name) {
            if ()
        }
    }
}