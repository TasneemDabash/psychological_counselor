# -*- coding: utf-8 -*-
import os
from dotenv import load_dotenv
from openai import OpenAI

# Load environment variables
load_dotenv()

# Initialize OpenAI client
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


def load_prompt(language="he"):
    if language == "en":
        with open("english_prompts.txt", "r", encoding="utf-8") as f:
            return f.read()
    else:
        with open("hebrew_prompts.txt", "r", encoding="utf-8") as f:
            return f.read()
        

def get_gpt_response(prompt, model="gpt-3.5-turbo", language="he"):
    try:
        system_prompt = load_prompt(language)
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt}
            ]
        )
        print("Sending to GPT:", prompt)
        return response.choices[0].message.content.strip()
    except Exception as e:
        return f"❌ Error: {e}"

# # -*- coding: utf-8 -*-
# import os
# from dotenv import load_dotenv
# from openai import OpenAI

# # Load environment variables
# load_dotenv()

# # Initialize OpenAI client
# client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


# def get_gpt_response(prompt, model="gpt-3.5-turbo"):
#     try:
#         response = client.chat.completions.create(
#             model=model,
#             messages=[
#                 {"role": "system", "content": "You are a helpful assistant for emotional reflection."},
#                 {"role": "user", "content": prompt}
#             ]
#         )
#         print("Sending to GPT:", prompt)
#         return response.choices[0].message.content.strip()
#     except Exception as e:
#         return f"❌ Error: {e}"


# def attribution_conversation():
#     print("שלום! אני כאן כדי לעזור לך לחשוב על אירוע שלילי שקרה לך לאחרונה.")
#     event_description = input("📌 תארי את האירוע בקצרה: ")

#     print("\n1️⃣ הערכת משמעות האירוע")

#     # significance = input("🔸 עד כמה האירוע משמעותי עבורך? (0–100): ")
#     significance = input("🔸 עד כמה האירוע משמעותי עבורך? (0–100): ")
#     negativity = input("🔸 עד כמה האירוע שלילי בעינייך? (0–100): ")

#     print("\n2️⃣ רגשות")
#     emotions = input("🔹 אילו רגשות עולים כשאת חושבת על האירוע הזה?: ")

#     print("\n3️⃣ סיבתיות")
#     reason = input("🔹 מה לדעתך הסיבה המרכזית שגרמה לאירוע הזה?: ")
#     if not reason or len(reason.split()) < 3:
#         print("💬 לפעמים קשה לחשוב על סיבה אחת ברורה. קחי רגע ונסי שוב.")
#         reason = input("🔸 הסיבה המרכזית: ")

#     print("\n4️⃣ שיקוף")
#     print(f"📖 האירוע: '{event_description}'")
#     print(f"📖 הסיבה: '{reason}'")
#     print(f"📖 הרגשות: '{emotions}'")

#     reflection_prompt = (
#         f"האירוע הוא: '{event_description}', "
#         f"הסיבה המרכזית: '{reason}', "
#         f"והרגשות שעולים הם: '{emotions}'."
#     )
#     reflection = get_gpt_response(reflection_prompt)
#     print(f"\n🤖 GPT משקף: {reflection}")

#     print("\n5️⃣ שכנוע")
#     conviction = input("🔸 עד כמה את משוכנעת שהסיבה הזו באמת גרמה לאירוע? (0–100): ")

#     try:
#         conviction_score = int(conviction)
#     except ValueError:
#         conviction_score = 50  # ברירת מחדל

#     if conviction_score < 50:
#         print("\n6️⃣ את לא משוכנעת בסיבה")
#         new_reason = input("🔹 האם יש גורם אחר שלדעתך תרם לאירוע?: ")
#         if new_reason:
#             reason = new_reason
#     else:
#         print("\n7️⃣ שאלות ייחוס")
#         internal_external = input("🔸 האם הסיבה תלויה בך או באחרים/נסיבות? (לגמרי בגללי ↔ לגמרי נסיבות): ")
#         scope = input("🔸 האם הסיבה תשפיע רק כאן או גם בתחומים אחרים?: ")
#         recurrence = input("🔸 האם זה עשוי לקרות שוב בעתיד? (לעולם לא ↔ תמיד): ")

#         print("\n8️⃣ שיקוף נוסף")
#         summary_prompt = (
#             f"הסיבה היא '{reason}', "
#             f"תלויה ב: '{internal_external}', "
#             f"משפיעה ב: '{scope}', "
#             f"וחוזרת ב: '{recurrence}'."
#         )
#         summary = get_gpt_response(summary_prompt)
#         print(f"\n🤖 GPT מסכם: {summary}")

#         print("\n9️⃣ אתגור ייחוס")
#         alt_scenario_prompt = f"האם תוכלי לחשוב על מצב דומה שבו '{reason}' לא גרמה לאירוע כזה?"
#         print(get_gpt_response(alt_scenario_prompt))

#         alt_cause_prompt = "האם ייתכן שיש סיבה אחרת שלא תלויה בך?"
#         print(get_gpt_response(alt_cause_prompt))

#     print("\n🔟 עידוד לפעולה")
#     action_prompt1 = f"מה אפשר לעשות כדי למנוע את הישנות האירוע '{event_description}'?"
#     print(get_gpt_response(action_prompt1))

#     action_prompt2 = "חשבי על צעד או פעולה שיכולה לעזור לך במצבים דומים בעתיד."
#     print(get_gpt_response(action_prompt2))

#     print("\n✅ תודה ששיתפת! אני מקווה שזה עזר לך לראות את הדברים מזווית חדשה.")


# if __name__ == "__main__":
#     attribution_conversation()