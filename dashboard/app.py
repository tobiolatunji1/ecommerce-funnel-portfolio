from pathlib import Path
import pandas as pd
import streamlit as st
import plotly.express as px

st.set_page_config(page_title="E-commerce Funnel Analysis", page_icon="🛒", layout="wide")
st.title("🛒 E-commerce Conversion Funnel")
st.caption("Project 01 · Google Merchandise Store sample · Nov 2020–Jan 2021")
st.info("Upload the CSV exports from the SQL folder to populate this dashboard. No results are fabricated or prefilled.")

BASE = Path(__file__).resolve().parent

def load_csv(filename, required_cols):
    uploaded = st.sidebar.file_uploader(f"Upload {filename}", type=["csv"], key=filename)
    path = BASE / filename
    try:
        df = pd.read_csv(uploaded) if uploaded is not None else (pd.read_csv(path) if path.exists() else None)
    except Exception as exc:
        st.error(f"Could not read {filename}: {exc}")
        return None
    if df is not None:
        missing = set(required_cols) - set(df.columns)
        if missing:
            st.warning(f"{filename} is missing columns: {', '.join(sorted(missing))}")
            return None
    return df

funnel = load_csv("overall_funnel.csv", ["funnel_step", "step_order", "users"])
device = load_csv("device_funnel.csv", ["device_category", "funnel_step", "step_order", "users"])
source = load_csv("source_funnel.csv", ["source", "medium", "funnel_step", "step_order", "users"])
daily = load_csv("daily_trend.csv", ["event_day", "product_view_users", "purchaser_users"])

if funnel is not None:
    funnel = funnel.sort_values("step_order")
    steps = funnel["users"].tolist()
    start_users = steps[0] if steps else 0
    end_users = steps[-1] if steps else 0
    overall_rate = end_users / start_users * 100 if start_users else 0
    lost_users = start_users - end_users
    a, b, c = st.columns(3)
    a.metric("Product-view users", f"{start_users:,.0f}")
    b.metric("Purchasers reaching all steps", f"{end_users:,.0f}")
    c.metric("View-to-purchase rate", f"{overall_rate:.2f}%")
    st.subheader("Overall funnel")
    funnel["step_label"] = funnel["funnel_step"]
    fig = px.funnel(funnel, x="users", y="step_label", title="Users reaching each qualifying step")
    st.plotly_chart(fig, use_container_width=True)
    if start_users:
        st.caption(f"{lost_users:,.0f} fewer users qualify at the final step than at product view. This is a user-level funnel based on events occurring within the date range, not proof of a single ordered session path.")
else:
    st.warning("Upload overall_funnel.csv to show the overall funnel and headline metrics.")

left, right = st.columns(2)
with left:
    st.subheader("Funnel by device")
    if device is not None:
        device = device.sort_values("step_order")
        fig = px.line(device, x="funnel_step", y="users", color="device_category", markers=True,
                      category_orders={"funnel_step": ["Product view", "Add to cart", "Begin checkout", "Purchase"]})
        st.plotly_chart(fig, use_container_width=True)
        st.dataframe(device, use_container_width=True, hide_index=True)
    else:
        st.caption("Upload device_funnel.csv to compare device categories.")
with right:
    st.subheader("Funnel by traffic source")
    if source is not None:
        source["source_medium"] = source["source"].astype(str) + " / " + source["medium"].astype(str)
        stage = st.selectbox("Funnel stage", source["funnel_step"].drop_duplicates().tolist(), key="source_stage")
        view = source[source["funnel_step"] == stage].sort_values("users", ascending=False).head(15)
        fig = px.bar(view, x="users", y="source_medium", orientation="h", title=f"Users at: {stage}")
        st.plotly_chart(fig, use_container_width=True)
    else:
        st.caption("Upload source_funnel.csv to compare acquisition sources and mediums.")

st.subheader("Daily trend")
if daily is not None:
    daily["event_day"] = pd.to_datetime(daily["event_day"])
    metric = st.radio("Measure", ["Users", "Events"], horizontal=True)
    if metric == "Users":
        cols = ["product_view_users", "purchaser_users"]
    else:
        cols = [c for c in ["product_view_events", "add_to_cart_events", "checkout_events", "purchase_events"] if c in daily.columns]
    fig = px.line(daily, x="event_day", y=cols, markers=False)
    st.plotly_chart(fig, use_container_width=True)
    st.dataframe(daily, use_container_width=True, hide_index=True)
else:
    st.caption("Upload daily_trend.csv to explore daily trends.")

with st.expander("Metric definitions and caveats"):
    st.markdown("""
    - **User-level funnel:** users qualify for later steps only when they also qualify for the earlier steps, but the events can occur in different sessions or orders within the date window.
    - **View-to-purchase rate:** qualifying purchasers divided by qualifying product viewers.
    - **Traffic source:** first observed source/medium in the selected export window; not causal attribution.
    - **Data caveat:** Google notes that this public sample is obfuscated and may have limited internal consistency.
    - For a stricter behavioral funnel, build a session-level ordered funnel using `ga_session_id` and event timestamps.
    """)
