import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import numpy as np
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

st.set_page_config(
    page_title="Hotel Booking Analysis Dashboard",
    page_icon="",
    layout="wide",
    initial_sidebar_state="expanded"
)

st.markdown("""
<style>
    .metric-card {
        background-color: #f0f2f6;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 5px solid #1f77b4;
    }
    .stMetric > label {
        font-size: 1rem !important;
        font-weight: bold !important;
    }
    .main-header {
        font-size: 3rem;
        font-weight: bold;
        text-align: center;
        color: #1f77b4;
        margin-bottom: 2rem;
    }
    .section-header {
        font-size: 1.5rem;
        font-weight: bold;
        color: #2c3e50;
        margin-top: 2rem;
        margin-bottom: 1rem;
    }
</style>
""", unsafe_allow_html=True)

@st.cache_data
def load_data():
    try:
        df = pd.read_csv('hotel_bookings.csv')
        
        df['total_nights'] = df['stays_in_weekend_nights'] + df['stays_in_week_nights']
        df['total_guests'] = df['adults'] + df['children'] + df['babies']
        df['arrival_date'] = pd.to_datetime(
            df['arrival_date_year'].astype(str) + '-' + 
            df['arrival_date_month'] + '-' + 
            df['arrival_date_day_of_month'].astype(str), 
            errors='coerce'
        )
        
        df['season'] = df['arrival_date_month'].map({
            'December': 'Winter', 'January': 'Winter', 'February': 'Winter',
            'March': 'Spring', 'April': 'Spring', 'May': 'Spring',
            'June': 'Summer', 'July': 'Summer', 'August': 'Summer',
            'September': 'Fall', 'October': 'Fall', 'November': 'Fall'
        })
        
        df['lead_time_category'] = pd.cut(df['lead_time'], 
                                        bins=[-1, 0, 7, 30, 90, 180, float('inf')],
                                        labels=['Same Day', '1-7 days', '1-4 weeks', 
                                               '1-3 months', '3-6 months', '6+ months'])
        
        df['stay_duration_category'] = pd.cut(df['total_nights'],
                                            bins=[-1, 1, 3, 7, 14, float('inf')],
                                            labels=['1 night', '2-3 nights', '4-7 nights',
                                                   '1-2 weeks', '2+ weeks'])
        
        df['total_revenue'] = df['total_nights'] * df['adr']
        
        df = df[df['adults'] > 0]
        df = df[df['adr'] >= 0]
        
        return df
    except Exception as e:
        st.error(f"Error loading data: {e}")
        return None

def create_kpi_metrics(df):
    total_bookings = len(df)
    cancellation_rate = (df['is_canceled'].sum() / total_bookings) * 100
    avg_stay = df['total_nights'].mean()
    total_revenue = df['total_revenue'].sum()
    avg_adr = df['adr'].mean()
    
    return {
        'total_bookings': total_bookings,
        'cancellation_rate': cancellation_rate,
        'avg_stay': avg_stay,
        'total_revenue': total_revenue,
        'avg_adr': avg_adr
    }

def plot_monthly_trends(df):
    monthly_data = df.groupby(['arrival_date_year', 'arrival_date_month']).agg({
        'is_canceled': ['count', 'mean']
    }).round(2)
    
    monthly_data.columns = ['total_bookings', 'cancellation_rate']
    monthly_data['cancellation_rate'] *= 100
    monthly_data = monthly_data.reset_index()
    
    # Create month-year for better x-axis
    month_order = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December']
    monthly_data['month_year'] = (monthly_data['arrival_date_month'] + ' ' + 
                                 monthly_data['arrival_date_year'].astype(str))
    
    fig = make_subplots(specs=[[{"secondary_y": True}]])
    
    fig.add_trace(
        go.Scatter(x=monthly_data['month_year'], y=monthly_data['total_bookings'],
                  mode='lines+markers', name='Total Bookings', line=dict(color='#1f77b4')),
        secondary_y=False,
    )
    
    fig.add_trace(
        go.Scatter(x=monthly_data['month_year'], y=monthly_data['cancellation_rate'],
                  mode='lines+markers', name='Cancellation Rate (%)', line=dict(color='#d62728')),
        secondary_y=True,
    )
    
    fig.update_xaxes(title_text="Month")
    fig.update_yaxes(title_text="Total Bookings", secondary_y=False)
    fig.update_yaxes(title_text="Cancellation Rate (%)", secondary_y=True)
    fig.update_layout(title_text="Monthly Booking Trends", height=400)
    
    return fig

def plot_hotel_comparison(df):
    hotel_stats = df.groupby('hotel').agg({
        'is_canceled': ['count', 'mean'],
        'total_nights': 'mean',
        'adr': 'mean',
        'total_revenue': 'sum'
    }).round(2)
    
    hotel_stats.columns = ['total_bookings', 'cancellation_rate', 'avg_stay', 'avg_adr', 'total_revenue']
    hotel_stats['cancellation_rate'] *= 100
    hotel_stats = hotel_stats.reset_index()
    
    fig = px.pie(hotel_stats, values='total_bookings', names='hotel',
                title='Bookings Distribution by Hotel Type',
                color_discrete_map={'City Hotel': '#1f77b4', 'Resort Hotel': '#ff7f0e'})
    fig.update_layout(height=400)
    
    return fig

def plot_cancellation_by_leadtime(df):
    leadtime_stats = df.groupby('lead_time_category')['is_canceled'].agg(['count', 'mean']).round(3)
    leadtime_stats.columns = ['total_bookings', 'cancellation_rate']
    leadtime_stats['cancellation_rate'] *= 100
    leadtime_stats = leadtime_stats.reset_index()
    
    fig = px.bar(leadtime_stats, x='lead_time_category', y='cancellation_rate',
                title='Cancellation Rate by Lead Time',
                color='cancellation_rate',
                color_continuous_scale='Reds')
    fig.update_layout(height=400)
    fig.update_xaxes(title="Lead Time Category")
    fig.update_yaxes(title="Cancellation Rate (%)")
    
    return fig

def plot_geographic_distribution(df):
    country_stats = df.groupby('country').agg({
        'is_canceled': ['count', 'mean'],
        'total_revenue': 'sum'
    }).round(2)
    
    country_stats.columns = ['total_bookings', 'cancellation_rate', 'total_revenue']
    country_stats['cancellation_rate'] *= 100
    country_stats = country_stats.reset_index()
    country_stats = country_stats.nlargest(15, 'total_bookings')
    
    fig = px.bar(country_stats, x='total_bookings', y='country',
                orientation='h', title='Top 15 Countries by Booking Volume',
                color='cancellation_rate', color_continuous_scale='RdYlGn_r')
    fig.update_layout(height=500)
    fig.update_xaxes(title="Total Bookings")
    fig.update_yaxes(title="Country")
    
    return fig

def plot_market_segment_analysis(df):
    segment_stats = df.groupby('market_segment').agg({
        'is_canceled': ['count', 'mean'],
        'adr': 'mean',
        'total_revenue': 'sum'
    }).round(2)
    
    segment_stats.columns = ['total_bookings', 'cancellation_rate', 'avg_adr', 'total_revenue']
    segment_stats['cancellation_rate'] *= 100
    segment_stats = segment_stats.reset_index()
    
    fig = px.treemap(segment_stats, path=['market_segment'], values='total_bookings',
                    color='cancellation_rate', color_continuous_scale='RdYlGn_r',
                    title='Market Segment Distribution (Size: Bookings, Color: Cancellation Rate)')
    fig.update_layout(height=400)
    
    return fig

def plot_seasonal_analysis(df):
    seasonal_stats = df.groupby(['season', 'hotel']).agg({
        'is_canceled': ['count', 'mean'],
        'adr': 'mean'
    }).round(2)
    
    seasonal_stats.columns = ['total_bookings', 'cancellation_rate', 'avg_adr']
    seasonal_stats['cancellation_rate'] *= 100
    seasonal_stats = seasonal_stats.reset_index()
    
    fig = px.bar(seasonal_stats, x='season', y='total_bookings',
                color='hotel', barmode='group',
                title='Seasonal Booking Distribution by Hotel Type')
    fig.update_layout(height=400)
    fig.update_xaxes(title="Season")
    fig.update_yaxes(title="Total Bookings")
    
    return fig

def main():
    # Header
    st.markdown('<h1 class="main-header">Hotel Booking Analysis Dashboard</h1>', 
                unsafe_allow_html=True)
    
    # Load data
    df = load_data()
    if df is None:
        st.stop()
    
    # Sidebar filters
    st.sidebar.header("Filters")
    
    # Hotel type filter
    hotel_types = ['All'] + list(df['hotel'].unique())
    selected_hotel = st.sidebar.selectbox("Select Hotel Type", hotel_types)
    
    # Year filter
    years = ['All'] + sorted(df['arrival_date_year'].unique())
    selected_year = st.sidebar.selectbox("Select Year", years)
    
    # Country filter (top 20)
    top_countries = df['country'].value_counts().head(20).index.tolist()
    countries = ['All'] + top_countries
    selected_country = st.sidebar.selectbox("Select Country", countries)
    
    # Apply filters
    filtered_df = df.copy()
    if selected_hotel != 'All':
        filtered_df = filtered_df[filtered_df['hotel'] == selected_hotel]
    if selected_year != 'All':
        filtered_df = filtered_df[filtered_df['arrival_date_year'] == selected_year]
    if selected_country != 'All':
        filtered_df = filtered_df[filtered_df['country'] == selected_country]
    
    # Display filter summary
    st.sidebar.markdown("---")
    st.sidebar.markdown(f"**Filtered Data**: {len(filtered_df):,} bookings")
    st.sidebar.markdown(f"**Original Data**: {len(df):,} bookings")
    
    # KPI Metrics
    st.markdown('<p class="section-header">Key Performance Indicators</p>', 
                unsafe_allow_html=True)
    
    kpis = create_kpi_metrics(filtered_df)
    
    col1, col2, col3, col4, col5 = st.columns(5)
    
    with col1:
        st.metric("Total Bookings", f"{kpis['total_bookings']:,}")
    
    with col2:
        cancellation_color = "normal"
        if kpis['cancellation_rate'] > 40:
            cancellation_color = "inverse"
        st.metric("Cancellation Rate", f"{kpis['cancellation_rate']:.1f}%")
    
    with col3:
        st.metric("Avg Length of Stay", f"{kpis['avg_stay']:.1f} nights")
    
    with col4:
        st.metric("Total Revenue", f"${kpis['total_revenue']:,.0f}")
    
    with col5:
        st.metric("Avg Daily Rate", f"${kpis['avg_adr']:.2f}")
    
    # Charts Section
    st.markdown('<p class="section-header">Booking Trends & Analysis</p>', 
                unsafe_allow_html=True)
    
    # Row 1: Monthly trends and hotel comparison
    col1, col2 = st.columns(2)
    with col1:
        if len(filtered_df) > 0:
            fig_monthly = plot_monthly_trends(filtered_df)
            st.plotly_chart(fig_monthly, use_container_width=True)
    
    with col2:
        if len(filtered_df) > 0:
            fig_hotel = plot_hotel_comparison(filtered_df)
            st.plotly_chart(fig_hotel, use_container_width=True)
    
    # Row 2: Lead time and geographic analysis
    col1, col2 = st.columns(2)
    with col1:
        if len(filtered_df) > 0:
            fig_leadtime = plot_cancellation_by_leadtime(filtered_df)
            st.plotly_chart(fig_leadtime, use_container_width=True)
    
    with col2:
        if len(filtered_df) > 0:
            fig_geo = plot_geographic_distribution(filtered_df)
            st.plotly_chart(fig_geo, use_container_width=True)
    
    # Row 3: Market segment and seasonal analysis
    col1, col2 = st.columns(2)
    with col1:
        if len(filtered_df) > 0:
            fig_segment = plot_market_segment_analysis(filtered_df)
            st.plotly_chart(fig_segment, use_container_width=True)
    
    with col2:
        if len(filtered_df) > 0:
            fig_seasonal = plot_seasonal_analysis(filtered_df)
            st.plotly_chart(fig_seasonal, use_container_width=True)
    
    # Data Insights Section
    st.markdown('<p class="section-header">Key Insights</p>', 
                unsafe_allow_html=True)
    
    # Calculate insights
    insights = []
    
    if kpis['cancellation_rate'] > 35:
        insights.append(f"High cancellation rate ({kpis['cancellation_rate']:.1f}%) - consider implementing retention strategies")
    
    resort_cancel = filtered_df[filtered_df['hotel'] == 'Resort Hotel']['is_canceled'].mean() * 100 if 'Resort Hotel' in filtered_df['hotel'].values else 0
    city_cancel = filtered_df[filtered_df['hotel'] == 'City Hotel']['is_canceled'].mean() * 100 if 'City Hotel' in filtered_df['hotel'].values else 0
    
    if resort_cancel > 0 and city_cancel > 0:
        if resort_cancel < city_cancel:
            insights.append(f"Resort hotels perform better with {resort_cancel:.1f}% vs {city_cancel:.1f}% cancellation rate")
        else:
            insights.append(f"City hotels perform better with {city_cancel:.1f}% vs {resort_cancel:.1f}% cancellation rate")
    
    if kpis['avg_stay'] < 2:
        insights.append("Short average stay - opportunity to promote longer packages")
    elif kpis['avg_stay'] > 5:
        insights.append("Strong guest retention with long average stays")
    
    # Display insights
    for insight in insights:
        st.markdown(f"- {insight}")
    
    if not insights:
        st.markdown("- Data looks healthy across all key metrics")
    
    # Raw Data Section (Optional)
    with st.expander("View Raw Data Sample"):
        st.dataframe(filtered_df.head(1000))
    
    # Footer
    st.markdown("---")
    st.markdown("**Hotel Booking Analysis Dashboard** | Built with Streamlit | Data-driven insights for hospitality management")

if __name__ == "__main__":
    main()
